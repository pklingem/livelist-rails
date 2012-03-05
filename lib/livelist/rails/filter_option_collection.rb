require 'active_support/hash_with_indifferent_access'
require 'livelist/rails/filter_option'

module Livelist
  module Rails

    class FilterOptionCollection < HashWithIndifferentAccess
      alias :options :values
      alias :find_option :[]

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

      def name_param(option)
        if [String, Symbol, Integer].any?{|klass| option.kind_of?(klass)}
          option
        elsif option.kind_of?(Hash) && option.has_key?(:name)
          option[:name]
        elsif option.respond_to?(:name)
          option.name
        else
         option[@slug]
        end
      end

      def slug_param(option)
        if [String, Symbol, Integer].any?{|klass| option.kind_of?(klass)}
          option
        else
          option[@slug]
        end
      end

      def option_params(option)
        options = {
          :filter => @filter,
          :slug   => slug_param(option),
          :name   => name_param(option)
        }
      end

      def create_option(option)
        params = option_params(option)
        self[params[:slug]] = FilterOption.new(params)	
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
