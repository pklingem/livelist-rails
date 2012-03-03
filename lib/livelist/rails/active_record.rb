require 'active_record'
require 'livelist/rails/filter'
require 'livelist/rails/filter_collection'

module Livelist
  module Rails
    module ActiveRecord

      def filter_for(filter_slug, options = {})
        @filter_collection ||= FilterCollection.new
        @filter_collection.create_filter(
          :model_name => model_name,
          :slug       => filter_slug,
          :base_query => scoped,
          :collection => options[:collection],
          :join       => options[:join],
          :group_by   => options[:group_by]
        )

        def filters(filter)
          filter.option_collection.options.map do |option|
            params = @filter_params[filter.slug]
            option.as_json(params)
          end
        end

        def filters_as_json(filter_params)
          @filter_params = filter_params || {}
          @filter_collection.filters.map do |filter|
            filter.option_collection.counts = filter.counts(scoped, @filter_params)
            filter.as_json(filters(filter))
          end
        end

        def filter(filter_params)
          filter_params ||= {}
          @filter_relation = @filter_collection.relation(filter_params, scoped)
        end
      end
    end
  end
end
