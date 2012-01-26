require 'active_record'

module Livelist
  module Rails
    module ActiveRecord

      @@counts = {}
      def filter_option_count(filter_slug, option)
        @@counts[filter_slug] = send("#{filter_slug}_filter_counts") unless @@counts.has_key?(filter_slug)
        @@counts[filter_slug][option.to_s] || 0
      end

      def filters(*filter_slugs)
        @@filter_slugs = filter_slugs
        @@filter_slugs.each do |filter_slug|
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
              option_objects = send("#{filter_slug}_filter_option_objects")
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
              option_objects = send("#{filter_slug}_filter_option_objects")
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
              option_slug  = send("#{filter_slug}_filter_option_slug", option)
              option_name  = send("#{filter_slug}_filter_option_name", option)
              option_value = send("#{filter_slug}_filter_option_value", option)
              option_count = send("#{filter_slug}_filter_option_count", option)

              {
                :slug     => option_slug,
                :name     => option_name,
                :value    => option_value,
                :count    => option_count,
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

        def self.filters_as_json(filter_params)
          filter_params ||= {}
          @@filter_slugs.map do |filter|
            filter_options = send("#{filter}_filters", filter_params[filter])
            send("#{filter}_filter", filter_options)
          end
        end

        def self.filter(filter_params)
          filter_params ||= {}
          query = scoped
          filter_params.each do |filter, values|
            query = query.send("#{filter}_relation", values)
          end
          query
        end
      end

    end
  end
end
