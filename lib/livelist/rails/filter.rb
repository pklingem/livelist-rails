require 'active_record'

module Livelist
  module Rails

    class Filter
      attr_accessor :slug, :collection, :key_name, :model_name, :type, :values

      @@filters = {}

      # slug should always be a symbol
      def initialize(options = {})
        @slug = options[:slug].to_sym
        @model_name = options[:model_name]
        @collection = initialize_collection(options[:collection])
        @type = options[:type] || initialize_type
        @key_name = options[:key_name] || default_key_name
        @values = initialize_values
        @@filters[@slug] = self
      end

      def default_key_name
        case @type
        when :association then :id
        when :attribute then @slug
        end
      end

      def initialize_type
        model_class = @model_name.classify.constantize
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

      def initialize_collection(collection)
        if collection
          if collection.respond_to?(:call)
            collection.call.map(&filter_slug.to_sym)
          elsif collection.any?{|object| object.kind_of?(Hash)}
            collection.map{|hash| HashWithIndifferentAccess.new(hash)}
          else
            collection
          end
        else
          default_collection
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

      def self.all
        @@filters
      end

      def self.find_by_slug(slug)
        @@filters[slug.to_sym]
      end

      def self.slugs
        @@filters.keys
      end

      def self.collections
        @@filters.values.map(&:collection)
      end
    end

  end
end
