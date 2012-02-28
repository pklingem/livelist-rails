require 'active_record'
require 'livelist/rails/filter_option'

module Livelist
  module Rails

    class Filter
      attr_accessor :slug, :name, :collection, :key_name, :model_name, :type, :values, :filter_options

      @@filters = {}

      # slug should always be a symbol
      def initialize(options = {})
        @slug            = options[:slug].to_sym
        @name            = options[:name] || @slug.to_s.capitalize
        @model_name      = options[:model_name]
        @type            = options[:type] || initialize_type
        @key_name        = options[:key_name] || default_key_name
        @filter_options  = initialize_filter_options(options[:collection])
        @collection      = @filter_options.map(&:slug)
        @values          = initialize_values
        @@filters[@slug] = self
      end

      def default_key_name
        case @type
        when :association then :id
        when :attribute   then @slug
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

      def self.all
        @@filters.values
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
