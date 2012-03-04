require 'active_record'
require 'livelist/rails/filter'
require 'livelist/rails/filter_collection'

module Livelist
  module Rails
    module ActiveRecord

      def filter_for(slug, options = {})
        @filter_collection ||= FilterCollection.new
        @filter_collection.create_filter(
          :model_name => model_name,
          :slug       => slug,
          :collection => options[:collection]
        )

        def filters_as_json(params)
          @filter_collection.as_json(scoped, params)
        end

        def filter(params)
          @filter_collection.relation(scoped, params)
        end
      end
    end
  end
end
