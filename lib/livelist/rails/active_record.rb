require 'active_record'
require 'livelist/rails/filter'

module Livelist
  module Rails
    module ActiveRecord
      def association_filter?(filter_slug)
        reflect_on_all_associations.map(&:name).include?(filter_slug.to_sym)
      end

      def attribute_filter?(filter_slug)
        column_names.include?(filter_slug)
      end

      def filter_for(filter_slug, options = {})
        Filter.new(:model_name => model_name, :slug => filter_slug, :collection => options[:collection])
        define_class_methods(filter_slug)

        def filters_as_json(filter_params)
          @counts = {}
          @filter_params = filter_params || {}
          Filter.slugs.map do |filter|
            filter_options = send("#{filter}_filters", filter)
            send("#{filter}_filter", filter_options)
          end
        end

        def filter_relation(filter_params)
          query = scoped
          Filter.all.each do |filter|
            default_filter_values = filter.values
            params_filter_values = filter_params[filter.slug.to_s]
            query = query.send("#{filter.slug}_join").send("#{filter.slug}_where", default_filter_values)
            query = query.send("#{filter.slug}_relation", params_filter_values) unless filter_params.empty?
          end
          query
        end

        def filter(filter_params)
          filter_params ||= {}
          @filter_relation = filter_relation(filter_params)
        end

        def filter_values(filter_slug)
          key = send("#{filter_slug}_filter_option_key_name")
          filter = Filter.find_by_slug(filter_slug)
          collection = filter.collection
          if collection.any?{|object| object.kind_of?(Hash) && object.has_key?(key)}
            collection.map{|object| object[key]}
          elsif collection.any?{|object| object.respond_to?(key)}
            collection.map(&key)
          elsif collection.kind_of?(Array)
            collection
          end
        end

        def filter_option_count(filter_slug, option)
          @counts[filter_slug] ||= send("#{filter_slug}_filter_counts").stringify_keys
          filter = Filter.find_by_slug(filter_slug)
          case filter.type
          when :association then @counts[filter_slug][option.send(:id).to_s] || 0
          when :attribute   then @counts[filter_slug][option.to_s] || 0
          end
        end

        def exclude_filter_relation?(filter_slug, slug)
          @filter_params[filter_slug].nil? || (slug.to_s == filter_slug)
        end

        def counts_relation(filter_slug, slug)
          query = scoped
          query = query.send("#{slug}_join")
          query = query.send("#{slug}_where", filter_values(slug))
          query = query.send("#{slug}_where", @filter_params[slug]) unless exclude_filter_relation?(filter_slug, slug)
          query
        end

        def filter_slug_filter_counts(filter_slug)
          query = scoped.except(:order)
          Filter.slugs.each do |slug|
            query = query.counts_relation(filter_slug, slug)
          end
          group_by = send("#{filter_slug}_counts_group_by")
          query.group(group_by).count
        end
      end

      def define_class_methods(filter_slug)
        filter_slug = filter_slug.to_s
        metaclass = class << self; self; end

        metaclass.instance_eval do
          define_method("#{filter_slug}_filter_values")          { Filter.find_by_slug(filter_slug).values }
          define_method("#{filter_slug}_filter_name")            { Filter.find_by_slug(filter_slug).name }
          define_method("#{filter_slug}_filter_slug")            { Filter.find_by_slug(filter_slug).slug }
          define_method("#{filter_slug}_counts_group_by")        { "#{model_name.tableize}.#{filter_slug}" }
          define_method("#{filter_slug}_join")                   { scoped }
          define_method("#{filter_slug}_filter_counts")          { filter_slug_filter_counts(filter_slug) }
          define_method("#{filter_slug}_filter_option_key_name") { Filter.find_by_slug(filter_slug).key_name }
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
            filter = Filter.find_by_slug(filter_slug)
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
            filter = Filter.find_by_slug(filter_slug)
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
            filter = Filter.find_by_slug(filter_slug)
            {
              :slug     => filter.slug,
              :name     => filter.name,
              :value    => send("#{filter_slug}_filter_option_value", option),
              :count    => send("#{filter_slug}_filter_option_count", option),
              :selected => selected
            }
          end

          define_method "#{filter_slug}_filters" do |filter|
            filter = Filter.find_by_slug(filter_slug)
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
