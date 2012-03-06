require 'active_record'
require 'livelist/rails/filter_collection'

module Livelist
  module Rails
    module ActiveRecord

      def filter_for(slug, options = {})
        @filters ||= FilterCollection.new
        @filters.create_filter(
          :reference_criteria => options[:reference_criteria],
          :model_name         => model_name,
          :slug               => slug
        )

        def filters_as_json(params)
          @filters.as_json(scoped, params)
        end

        def filter(params)
          @filters.relation(scoped, params)
        end
      end

    end
  end
end
