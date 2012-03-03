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

        def filter_option_value(option)
          [String, Integer].any?{|klass| option.kind_of?(klass)} ? option.to_s : option.send(:id).to_s
        end

        def filter_option_count(filter, option)
          case filter.type
          when :association then @counts[filter.slug][option.send(:id).to_s] || 0
          when :attribute   then @counts[filter.slug][option.to_s] || 0
          end
        end

        def filter_option(filter, option, selected)
          {
            :slug     => filter.slug,
            :name     => filter.name,
            :value    => filter_option_value(option),
            :count    => filter_option_count(filter, option),
            :selected => selected
          }
        end

        def filters(filter)
          filter.option_slugs.map do |option|
            selected = @filter_params[filter.slug].nil? ? false : @filter_params[filter.slug].include?(option.to_s)
            filter_option(filter, option, selected)
          end
        end

        def filters_as_json(filter_params)
          @counts = {}
          @filter_params = filter_params || {}
          @filter_collection.filters.map do |filter|
            @counts[filter.slug] ||= filter.counts(scoped, @filter_params)
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
