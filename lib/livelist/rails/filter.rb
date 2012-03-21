require 'active_record'
require 'livelist/rails/filter_criteria'

module Livelist
  module Rails

    class Filter
      DEFAULT_FILTER_OPTIONS = {
        :reference_criteria => nil
      }

      attr_accessor :slug,
                    :name,
                    :key_name,
                    :model_name,
                    :model_class,
                    :join,
                    :type,
                    :criteria

      # slug should always be a symbol
      def initialize(options = {})
        @filter_collection = options[:filter_collection]
        @slug              = options[:slug].to_sym
        @name              = options[:name] || @slug.to_s.capitalize
        @model_name        = options[:model_name]
        @type              = options[:type] || initialize_type
        @key_name          = options[:key_name] || default_key_name
        @criteria          = FilterCriteria.new(
                               :filter => self,
                               :reference_criteria => options[:reference_criteria],
                               :slug => @key_name
                             )
      end

      def prepare_options(options)
        options ||= {}
        options.reverse_merge!(DEFAULT_FILTER_OPTIONS)
        @criteria.set_criteria(options[:reference_criteria]) if options[:reference_criteria]
      end

      def group_by
        case @type
        when :attribute then "#{model_name.tableize}.#{@slug}"
        when :association then "#{@slug}.id"
        end
      end

      def exclude_filter_relation?(matching_filter, params)
        params.nil? || (self == matching_filter)
      end

      def set_criteria_counts(query, params)
        @criteria.counts = counts(query, params)
      end

      def counts_relation(query, filter, params)
        exclude_params_relation = exclude_filter_relation?(filter, params[@slug])
        counts_scope = filter.relation(query, params[filter.slug], exclude_params_relation)
        query.merge(counts_scope)
      end

      def counts(query, params)
        @filter_collection.filters.each do |filter|
          query = counts_relation(query, filter, params)
        end
        query.except(:order).group(group_by).count.stringify_keys
      end

      def relation(query, params, exclude_params_relation)
        query = query.includes(@slug) if @type == :association
        query = query.where(where(@criteria.slugs))
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
          :options => @criteria.as_json(params)
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
    end

  end
end
