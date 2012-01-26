require 'active_record'

module Livelist
  module Rails
    module ActiveRecord

      def filters(*filter_slugs)
        @@filter_slugs = filter_slugs
        @@counts = {}
        @@option_objects = {}

        @@filter_slugs.each do |filter_slug|
          define_class_methods(filter_slug)
        end

        def filters_as_json(filter_params)
          filter_params ||= {}
          @@filter_slugs.map do |filter|
            filter_options = send("#{filter}_filters", filter_params[filter])
            send("#{filter}_filter", filter_options)
          end
        end

        def filter(filter_params)
          filter_params ||= {}
          query = scoped
          filter_params.each do |filter, values|
            query = query.send("#{filter}_relation", values)
          end
          query
        end

        def filter_option_count(filter_slug, option)
          @@counts[filter_slug] = send("#{filter_slug}_filter_counts") unless @@counts.has_key?(filter_slug)
          @@counts[filter_slug][option.to_s] || 0
        end

        def cached_option_objects(filter_slug)
          @@option_objects[filter_slug] = send("#{filter_slug}_filter_option_objects") unless @@option_objects.has_key?(filter_slug)
          @@option_objects[filter_slug]
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

          define_method "#{filter_slug}_filter_option_objects" do
            select("distinct #{filter_slug}").all
          end

          define_method "#{filter_slug}_filter_values" do
            key = send("#{filter_slug}_filter_option_key_name")
            option_objects = cached_option_objects(filter_slug)
            if option_objects.any?{|object| object.kind_of?(Hash) && object.has_key?(key)}
              option_objects.map{|object| object[key]}
            elsif option_objects.any?{|object| object.respond_to?(key)}
              option_objects.map(&key)
            end
          end

          define_method "#{filter_slug}_filter_counts" do
            group(filter_slug).count
          end

          define_method "#{filter_slug}_filter_option_slug" do |option|
            if [String, Integer].any?{|klass| option.kind_of?(klass)}
              option.to_s
            else
              option.send(:id).to_s
            end
          end

          define_method "#{filter_slug}_filter_option_name" do |option|
            option_objects = cached_option_objects(filter_slug)
            if option_objects.any?{|object| object.kind_of?(Hash) && object.has_key?(:name)}
              option_object = option_objects.detect{|object| object[:state] == option.to_s}
              option_object[:name]
            elsif option_objects.any?{|object| object.respond_to?(:name)}
              option_object = option_objects.detect{|object| object.send(:id).to_s == option.to_s}
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

          define_method "#{filter_slug}_filter_option_selected?" do |filter_params, option|
            filter_params.nil? ? false : filter_params.include?(option.to_s)
          end

          define_method "#{filter_slug}_filters" do |filter_params|
            send("#{filter_slug}_filter_values").map do |option|
              selected = send("#{filter_slug}_filter_option_selected?", filter_params, option)
              send("#{filter_slug}_filter_option", option, selected)
            end
          end

          define_method "#{filter_slug}_relation" do |values|
            where(model_name.to_s.tableize => { filter_slug => values })
          end
        end
      end
    end
  end
end
