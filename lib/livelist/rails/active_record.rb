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

        def filters_as_json(filter_params)
          @counts = {}
          @filter_params = filter_params || {}
          @filter_collection.slugs.map do |filter|
            filter_options = send("#{filter}_filters", filter)
            send("#{filter}_filter", filter_options)
          end
        end

        def filter_relation(filter_params)
          query = scoped
          @filter_collection.filters.each do |filter|
            default_filter_values = filter.values
            params_filter_values = filter_params[filter.slug.to_s]
            query = query.includes(filter.join) if filter.type == :association
            query = query.send("#{filter.slug}_where", default_filter_values)
            query = query.send("#{filter.slug}_relation", params_filter_values) unless filter_params.empty?
          end
          query
        end

        def filter(filter_params)
          filter_params ||= {}
          @filter_relation = filter_relation(filter_params)
        end

        def filter_option_count(filter_slug, option)
          @counts[filter_slug] ||= send("#{filter_slug}_filter_counts").stringify_keys
          filter = @filter_collection.find_filter(filter_slug)
          case filter.type
          when :association then @counts[filter_slug][option.send(:id).to_s] || 0
          when :attribute   then @counts[filter_slug][option.to_s] || 0
          end
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
          define_method("#{filter_slug}_filter_name")            { @filter_collection.find_filter(filter_slug).name }
          define_method("#{filter_slug}_filter_slug")            { @filter_collection.find_filter(filter_slug).slug }
          define_method("#{filter_slug}_filter_counts")          { filter_slug_filter_counts(filter_slug) }
          define_method("#{filter_slug}_filter_option_key_name") { @filter_collection.find_filter(filter_slug).key_name }
          define_method("#{filter_slug}_where")                  { |values| where(model_name.tableize => { filter_slug => values }) }
          define_method("#{filter_slug}_relation")               { |values| send("#{filter_slug}_where", values) }
          define_method("#{filter_slug}_filter_option_count")    { |option| filter_option_count(filter_slug, option) }

          define_method("#{filter_slug}_name_key_or_method") do
            :name
          end

          define_method("#{filter_slug}_filter_option_value") do |option|
            [String, Integer].any?{|klass| option.kind_of?(klass)} ? option.to_s : option.send(:id).to_s
          end

          define_method("#{filter_slug}_filter_option_selected?") do |filter, option|
            @filter_params[filter].nil? ? false : @filter_params[filter].include?(option.to_s)
          end

          define_method "#{filter_slug}_filter" do |options|
            filter = @filter_collection.find_filter(filter_slug)
            {
              :filter_slug => filter.slug,
              :name => filter.name,
              :options => options
            }
          end

          define_method "#{filter_slug}_filter_option_slug" do |option|
            if [String, Integer].any?{|klass| option.kind_of?(klass)}
              option.to_s
            else
              option.send(:id).to_s
            end
          end

          define_method "#{filter_slug}_filter_option_name" do |option|
            filter = @filter_collection.find_filter(filter_slug)
            collection = filter.collection
            key = send("#{filter_slug}_name_key_or_method")
            if collection.any?{|object| object.kind_of?(Hash) && object.has_key?(key)}
              option_object = collection.detect{|object| object[filter_slug.to_s] == option.to_s}
              option_object[key]
            elsif collection.any?{|object| object.respond_to?(key)}
              if filter.type == :association
                option_object = collection.detect{|object| object.send(:id) == option}
              elsif filter.type == :attribute
                option_object = collection.detect{|object| object.send(:id).to_s == option.to_s}
              end
              option_object.send(key)
            else
              option.to_s
            end
          end

          define_method "#{filter_slug}_filter_option" do |option, selected|
            filter = @filter_collection.find_filter(filter_slug)
            {
              :slug     => filter.slug,
              :name     => filter.name,
              :value    => send("#{filter_slug}_filter_option_value", option),
              :count    => send("#{filter_slug}_filter_option_count", option),
              :selected => selected
            }
          end

          define_method "#{filter_slug}_filters" do |filter|
            filter = @filter_collection.find_filter(filter_slug)
            filter.values.map do |option|
              selected = send("#{filter_slug}_filter_option_selected?", filter, option)
              send("#{filter_slug}_filter_option", option, selected)
            end
          end
        end
      end
    end
  end
end
