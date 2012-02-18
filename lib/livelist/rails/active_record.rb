require 'active_record'

module Livelist
  module Rails
    module ActiveRecord
      @@filter_slugs = []
      @@filter_collections = {}

      def filter_for(filter_slug, options = {})
        @@filter_slugs << filter_slug unless @@filter_slugs.include?(filter_slug)
        @@filter_collections[filter_slug] = options[:collection] || lambda { select("distinct #{filter_slug}") }

        define_class_methods(filter_slug)

        def filters_as_json(filter_params)
          @counts = {}
          @filter_params = filter_params || {}
          filters = @@filter_slugs.map do |filter|
            filter_options = send("#{filter}_filters", filter)
            send("#{filter}_filter", filter_options)
          end
        end

        def filter_relation(filter_params)
          query = scoped
          @@filter_slugs.each do |filter_slug|
            default_filter_values = filter_values(filter_slug)
            params_filter_values = filter_params[filter_slug.to_s]
            query = query.send("#{filter_slug}_join").send("#{filter_slug}_where", default_filter_values)
            query = query.send("#{filter_slug}_relation", params_filter_values) unless filter_params.empty?
          end
          query
        end

        def filter(filter_params)
          filter_params ||= {}
          @filter_relation = filter_relation(filter_params)
        end

        def filter_values(filter_slug)
          key = send("#{filter_slug}_filter_option_key_name")
          collection = filter_collection(filter_slug)
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
          @counts[filter_slug][option.to_s] || 0
        end

				def filter_collection(filter_slug)
					collection = @@filter_collections[filter_slug.to_sym]
          if collection.respond_to?(:call)
            collection.call.map(&filter_slug.to_sym)
          else
            collection
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
          @@filter_slugs.each do |slug|
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
          define_method("#{filter_slug}_filter_values")          { filter_values(filter_slug) }
          define_method("#{filter_slug}_filter_name")            { filter_slug.capitalize }
          define_method("#{filter_slug}_filter_slug")            { filter_slug }
          define_method("#{filter_slug}_counts_group_by")        { "#{model_name.tableize}.#{filter_slug}" }
          define_method("#{filter_slug}_join")                   { scoped }
          define_method("#{filter_slug}_filter_counts")          { filter_slug_filter_counts(filter_slug) }
          define_method("#{filter_slug}_filter_option_key_name") { new.respond_to?(filter_slug.to_sym) ? filter_slug.to_sym : :id }
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
            {
              :filter_slug => send("#{filter_slug}_filter_slug"),
              :name => send("#{filter_slug}_filter_name"),
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
            collection = filter_collection(filter_slug)
            key = send("#{filter_slug}_name_key_or_method")
            if collection.any?{|object| object.kind_of?(Hash) && object.has_key?(key)}
              option_object = collection.detect{|object| object[:state] == option.to_s}
              option_object[key]
            elsif collection.any?{|object| object.respond_to?(key)}
              option_object = collection.detect{|object| object.send(:id).to_s == option.to_s}
              option_object.send(key)
            else
              option.to_s
            end
          end

          define_method "#{filter_slug}_filter_option" do |option, selected|
            {
              :slug     => send("#{filter_slug}_filter_option_slug", option),
              :name     => send("#{filter_slug}_filter_option_name", option),
              :value    => send("#{filter_slug}_filter_option_value", option),
              :count    => send("#{filter_slug}_filter_option_count", option),
              :selected => selected
            }
          end

          define_method "#{filter_slug}_filters" do |filter|
            send("#{filter_slug}_filter_values").map do |option|
              selected = send("#{filter_slug}_filter_option_selected?", filter, option)
              send("#{filter_slug}_filter_option", option, selected)
            end
          end
        end
      end
    end
  end
end
