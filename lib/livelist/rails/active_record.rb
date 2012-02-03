require 'active_record'

module Livelist
  module Rails
    module ActiveRecord
      @@filter_slugs = []
      @@filter_collections = {}

      def filter_for(filter_slug, options = {})
        @@counts = {}

        @@filter_slugs << filter_slug unless @@filter_slugs.include?(filter_slug)
        @@filter_collections[filter_slug] = options[:collection] || lambda { select("distinct #{filter_slug}") }

        define_class_methods(filter_slug)

        def filters_as_json(filter_params)
          @@filter_params = filter_params || {}
          @@filter_slugs.map do |filter|
            filter_options = send("#{filter}_filters", filter)
            send("#{filter}_filter", filter_options)
          end
        end

        def filter_relation(filter_params)
          relation = scoped
          @@filter_slugs.each do |filter_slug|
            values = filter_params[filter_slug.to_s]
            relation = relation.send("#{filter_slug}_relation", values) unless filter_params.empty?
          end
          relation
        end

        def filter(filter_params)
          filter_params ||= {}
          @@filter_relation = filter_relation(filter_params)
        end

        def filter_option_count(filter_slug, option)
          @@counts[filter_slug] = send("#{filter_slug}_filter_counts") unless @@counts.has_key?(filter_slug)
          @@counts[filter_slug][option.to_s] || 0
        end

				def filter_collection(filter_slug)
					collection = @@filter_collections[filter_slug.to_sym]
					collection.respond_to?(:call) ? collection.call : collection
				end
      end

      def define_class_methods(filter_slug)
        filter_slug = filter_slug.to_s
        metaclass = class << self; self; end

        metaclass.instance_eval do
          define_method "#{filter_slug}_filter_name" do
            filter_slug.capitalize
          end

          define_method "#{filter_slug}_filter_slug" do
            filter_slug
          end

          define_method "#{filter_slug}_filter" do |options|
            {
              :filter_slug => send("#{filter_slug}_filter_slug"),
              :name => send("#{filter_slug}_filter_name"),
              :options => options
            }
          end

          define_method "#{filter_slug}_filter_option_key_name" do
            new.respond_to?(filter_slug.to_sym) ? filter_slug.to_sym : :id
          end

          define_method "#{filter_slug}_filter_values" do
            key = send("#{filter_slug}_filter_option_key_name")
            collection = filter_collection(filter_slug)
            if collection.any?{|object| object.kind_of?(Hash) && object.has_key?(key)}
              collection.map{|object| object[key]}
            elsif collection.any?{|object| object.respond_to?(key)}
              collection.map(&key)
            end
          end

          define_method "#{filter_slug}_counts_group_by" do
            filter_slug
          end

          define_method "#{filter_slug}_join" do
            scoped
          end

          define_method "#{filter_slug}_where" do |values|
            where(model_name.to_s.tableize => { filter_slug => values })
          end

          define_method "#{filter_slug}_filter_counts" do
            query = scoped.except(:order)
            @@filter_slugs.each do |slug|
              query = query.send("#{slug}_join")
              query = query.send("#{slug}_where", @@filter_params[slug]) unless @@filter_params[filter_slug].nil? || (slug.to_s == filter_slug)
            end
            group_by = send("#{filter_slug}_counts_group_by")
            query.group(group_by).count
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
            if collection.any?{|object| object.kind_of?(Hash) && object.has_key?(:name)}
              option_object = collection.detect{|object| object[:state] == option.to_s}
              option_object[:name]
            elsif collection.any?{|object| object.respond_to?(:name)}
              option_object = collection.detect{|object| object.send(:id).to_s == option.to_s}
              option_object.send(:name)
            else
              option.to_s
            end
          end

          define_method "#{filter_slug}_filter_option_value" do |option|
            if [String, Integer].any?{|klass| option.kind_of?(klass)}
              option.to_s
            else
              option.send(:id).to_s
            end
          end

          define_method "#{filter_slug}_filter_option_count" do |option|
            filter_option_count(filter_slug, option)
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

          define_method "#{filter_slug}_filter_option_selected?" do |filter, option|
            @@filter_params[filter].nil? ? false : @@filter_params[filter].include?(option.to_s)
          end

          define_method "#{filter_slug}_filters" do |filter|
            send("#{filter_slug}_filter_values").map do |option|
              selected = send("#{filter_slug}_filter_option_selected?", filter, option)
              send("#{filter_slug}_filter_option", option, selected)
            end
          end

          define_method "#{filter_slug}_relation" do |values|
            send("#{filter_slug}_join").send("#{filter_slug}_where", values)
          end
        end
      end
    end
  end
end
