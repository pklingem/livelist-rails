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

        def filters_as_json(filter_params)
          @filter_collection.as_json(scoped, filter_params)
        end

        def filter(filter_params)
          @filter_collection.relation(scoped, filter_params)
        end
      end
    end
  end
end
