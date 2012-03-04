require 'active_record'
require 'livelist/rails/filter_option'
require 'livelist/rails/filter_option_collection'

module Livelist
  module Rails

    class Filter
      attr_accessor :slug,
                    :name,
                    :key_name,
                    :model_name,
                    :group_by,
                    :join,
                    :type,
                    :option_collection

      # slug should always be a symbol
      def initialize(options = {})
        @filter_collection = options[:filter_collection]
        @slug              = options[:slug].to_sym
        @name              = options[:name] || @slug.to_s.capitalize
        @base_query        = options[:base_query]
        @join              = options[:join] || @base_query
        @model_name        = options[:model_name]
        @group_by          = options[:group_by] || "#{model_name.tableize}.#{@slug}"
        @type              = options[:type] || initialize_type
        @key_name          = options[:key_name] || default_key_name
        @option_collection = FilterOptionCollection.new(:filter => self, :collection => options[:collection], :slug => @key_name)
      end

      def exclude_filter_relation?(matching_filter, params)
        params.nil? || (self == matching_filter)
      end

      def set_option_counts(query, params)
        @option_collection.counts = counts(query, params)
      end

      def counts(query, params)
        query = query.except(:order)
        @filter_collection.filters.each do |matching_filter|
          exclude_params_relation = exclude_filter_relation?(matching_filter, params[@slug])
          counts_scope = matching_filter.relation(query, params[matching_filter.slug], exclude_params_relation)
          query = query.merge(counts_scope)
        end
        counts = query.group(@group_by).count.stringify_keys
        counts
      end

      def relation(query, params, exclude_params_relation)
        query = query.includes(@join) if @type == :association
        query = query.where(where(option_slugs))
        query = query.where(where(params)) unless exclude_params_relation
        query
      end

      def default_key_name
        case @type
        when :association then :id
        when :attribute   then @slug
        end
      end

      def table_name
        case @type
        when :association then @slug
        when :attribute   then model_name.tableize
        end
      end

      def model_class
        @model_name.classify.constantize
      end

      def where(slug_params)
        { table_name => { @key_name => slug_params } }
      end

      def as_json(params)
        {
          :filter_slug => @slug,
          :name => @name,
          :options => @option_collection.as_json(params)
        }
      end

      def initialize_type
        if model_class.column_names.include?(@slug.to_s)
          :attribute
        elsif model_class.reflect_on_all_associations.map(&:name).include?(@slug)
          :association
        else
          nil
        end
      end

      def option_slugs
        @option_collection.slugs
      end
    end

  end
end
