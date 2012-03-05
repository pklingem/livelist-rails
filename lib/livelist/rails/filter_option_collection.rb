require 'active_support/hash_with_indifferent_access'
require 'livelist/rails/filter_option'

module Livelist
  module Rails

    class FilterOptionCollection < HashWithIndifferentAccess
      alias :options :values
      alias :find_option :[]
      attr_reader :slug

      def initialize(options)
        @filter     = options[:filter]
        @collection = options[:collection] || default_collection
        @collection = @collection.call if @collection.respond_to?(:call)
        @slug       = options[:slug]

        @collection.each do |option|
          create_option(option)
        end
      end

      def default_collection
        @filter.model_class.select("distinct #{@filter.slug}")
      end

      def create_option(option)
        filter_option = FilterOption.new(:filter => @filter, :option_collection => self, :option => option)
        self[filter_option.slug] = filter_option
      end

      def slugs
        options.map(&:slug)
      end

      def counts=(counts_hash)
        options.each do |option|
          option.count = counts_hash[option.slug.to_s] || 0
        end
      end

      def as_json(params)
        options.map do |option|
          option.as_json(params)
        end
      end
    end

  end
end
