require 'active_support/hash_with_indifferent_access'
require 'livelist/rails/filter'

module Livelist
  module Rails

    class FilterCollection < HashWithIndifferentAccess
      alias :filters :values
      alias :find_filter :[]

      def create_filter(options)
        options.merge!(:filter_collection => self)
        self[options[:slug]] = Filter.new(options)
      end

      def relation(query, params)
        params ||= {}
        filters.each do |filter|
          query = filter.relation(query, params[filter.slug.to_s], params.empty?)
        end
        query
      end

      def as_json(query, params)
        params ||= {}
        filters.map do |filter|
          filter.set_option_counts(query, params)
          filter.as_json(params[filter.slug])
        end
      end
    end

  end
end
