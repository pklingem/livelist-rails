require 'active_record'
require 'livelist/rails/filter_collection'

module Livelist
  module Rails
    module ActiveRecord

      def filters
        @filters ||= FilterCollection.new
      end

      def filter_for(slug, options = {})
        filters.create_filter(
          options.merge(
            :model_name => model_name,
            :slug       => slug
          )
        )
      end

      def filters_as_json(params, options = {})
        filters.as_json(scoped, params, options)
      end

      def filter(params, options = {})
        filters.relation(scoped, params, options)
      end

    end
  end
end
