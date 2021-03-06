require 'active_support/hash_with_indifferent_access'
require 'livelist/rails/filter_criterion'

module Livelist
  module Rails

    class FilterCriteria < HashWithIndifferentAccess
      alias :criteria :values
      alias :find_criteria :[]
      attr_reader :slug, :metadata_properties

      def initialize(options)
        @filter              = options[:filter]
        @slug                = options[:slug]
        @metadata_properties = options[:metadata_properties] || {}

        initialize_criteria(options[:reference_criteria])
      end

      def initialize_criteria(reference_criteria)
        reference_criteria ||= default_reference_criteria
        reference_criteria = reference_criteria.call if reference_criteria.respond_to?(:call)
        reference_criteria.each { |reference| create_criterion(reference) }
      end

      def set_criteria(reference_criteria)
        clear
        reference_criteria.each { |reference| create_criterion(reference) }
      end

      def default_reference_criteria
        case @filter.type
        when :attribute then @filter.model_class.select("distinct #{@filter.slug}")
        when :association then @filter.filter_class.scoped
        end
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
