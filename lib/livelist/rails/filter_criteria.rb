require 'active_support/hash_with_indifferent_access'
require 'livelist/rails/filter_criterion'

module Livelist
  module Rails

    class FilterCriteria < HashWithIndifferentAccess
      alias :criteria :values
      alias :find_criteria :[]
      attr_reader :slug

      def initialize(options)
        @filter     = options[:filter]
        @collection = options[:collection] || default_collection
        @collection = @collection.call if @collection.respond_to?(:call)
        @slug       = options[:slug]

        @collection.each do |reference|
          create_criterion(reference)
        end
      end

      def default_collection
        @filter.model_class.select("distinct #{@filter.slug}")
      end

      def create_criterion(reference)
        filter_criterion = FilterCriterion.new(:filter => @filter, :criteria => self, :reference => reference)
        self[filter_criterion.slug] = filter_criterion
      end

      def slugs
        criteria.map(&:slug)
      end

      def counts=(counts_hash)
        criteria.each do |criterion|
          criterion.count = counts_hash[criterion.slug.to_s] || 0
        end
      end

      def as_json(params)
        criteria.map do |criterion|
          criterion.as_json(params)
        end
      end
    end

  end
end
