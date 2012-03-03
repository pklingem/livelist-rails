require 'active_record'
require 'livelist/rails/filter_option'

module Livelist
  module Rails

    class Filter
      attr_accessor :slug,
                    :name,
                    :collection,
                    :key_name,
                    :model_name,
                    :group_by,
                    :join,
                    :type,
                    :values,
                    :filter_options

      # slug should always be a symbol
      def initialize(options = {})
        @slug            = options[:slug].to_sym
        @name            = options[:name] || @slug.to_s.capitalize
        @base_query      = options[:base_query]
        @join            = options[:join] || @base_query
        @model_name      = options[:model_name]
        @group_by        = options[:group_by] || "#{model_name.tableize}.#{@slug}"
        @type            = options[:type] || initialize_type
        @key_name        = options[:key_name] || default_key_name
        @filter_options  = initialize_filter_options(options[:collection])
        @collection      = @filter_options.map(&:slug)
        @values          = initialize_values
      end

      def exclude_filter_relation?(matching_filter, params)
        params.nil? || (self == matching_filter)
      end

      def counts_relation(query, params, exclude_params_relation)
        query = query.includes(@join) if @type == :association
        query = query.where(where(@values))
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

      def where(values)
        { table_name => { @key_name => values } }
      end

      def as_json(options)
        {
          :filter_slug => @slug,
          :name => @name,
          :options => options
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

      def default_collection
        lambda { select("distinct #{@slug}") }
      end

      def initialize_filter_options(collection)
        collection ||= default_collection
        collection = collection.call if collection.respond_to?(:call)
        collection.map do |filter_option|
          FilterOption.new(:slug => filter_option[@key_name], :name => filter_option[:name])
        end
      end

      def initialize_values
        if collection.any?{|object| object.kind_of?(Hash) && object.has_key?(key_name)}
          collection.map{|object| object[key_name]}
        elsif collection.any?{|object| object.respond_to?(key_name)}
          collection.map(&key_name)
        elsif collection.kind_of?(Array)
          collection
        end
      end
    end

  end
end
