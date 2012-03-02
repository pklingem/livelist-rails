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
        define_class_methods(filter_slug)

        def filter_option_value(option)
          [String, Integer].any?{|klass| option.kind_of?(klass)} ? option.to_s : option.send(:id).to_s
        end

        def filter_option_count(filter_slug, option)
          @counts[filter_slug] ||= filter_slug_filter_counts(filter_slug).stringify_keys
          filter = @filter_collection.find_filter(filter_slug)
          case filter.type
          when :association then @counts[filter_slug][option.send(:id).to_s] || 0
          when :attribute   then @counts[filter_slug][option.to_s] || 0
          end
        end

        def filter_option(filter_slug, option, selected)
          filter = @filter_collection.find_filter(filter_slug)
          {
            :slug     => filter.slug,
            :name     => filter.name,
            :value    => filter_option_value(option),
            :count    => filter_option_count(filter_slug, option),
            :selected => selected
          }
        end

        def filters(filter_slug)
          filter = @filter_collection.find_filter(filter_slug)
          filter.values.map do |option|
            selected = @filter_params[filter.slug].nil? ? false : @filter_params[filter.slug].include?(option.to_s)
            filter_option(filter_slug, option, selected)
          end
        end

        def filter_hash(filter_slug, options)
          filter = @filter_collection.find_filter(filter_slug)
          {
            :filter_slug => filter.slug,
            :name => filter.name,
            :options => options
          }
        end

        def filters_as_json(filter_params)
          @counts = {}
          @filter_params = filter_params || {}
          @filter_collection.slugs.map do |filter|
            filter_options = filters(filter)
            filter_hash(filter, filter_options)
          end
        end

        def filter_relation(filter_params)
          query = scoped
          @filter_collection.filters.each do |filter|
            default_filter_values = filter.values
            params_filter_values = filter_params[filter.slug.to_s]
            query = query.includes(filter.join) if filter.type == :association
            query = query.send("#{filter.slug}_where", default_filter_values)
            query = query.send("#{filter_slug}_where", params_filter_values) unless filter_params.empty?
          end
          query
        end

        def filter(filter_params)
          filter_params ||= {}
          @filter_relation = filter_relation(filter_params)
        end

        def exclude_filter_relation?(filter_slug, slug)
          @filter_params[filter_slug].nil? || (slug.to_s == filter_slug)
        end

        def counts_relation(filter_slug, slug)
          filter = @filter_collection.find_filter(slug)
          query = scoped
          query = query.includes(filter.join) if filter.type == :association
          query = query.send("#{slug}_where", filter.values)
          query = query.send("#{slug}_where", @filter_params[slug]) unless exclude_filter_relation?(filter_slug, slug)
          query
        end

        def filter_slug_filter_counts(filter_slug)
          filter = @filter_collection.find_filter(filter_slug)
          query = scoped.except(:order)
          @filter_collection.slugs.each do |slug|
            query = query.counts_relation(filter_slug, slug)
          end
          group_by = filter.group_by
          query.group(group_by).count
        end
      end

      def define_class_methods(filter_slug)
        filter_slug = filter_slug.to_s
        metaclass = class << self; self; end

        metaclass.instance_eval do
          define_method("#{filter_slug}_where") { |values| where(model_name.tableize => { filter_slug => values }) }
        end
      end
    end
  end
end
