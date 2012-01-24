require 'active_record'

module Livelist
  module Rails
    module ActiveRecord

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

            define_method "#{filter_slug}_filter_values" do
              select("distinct #{filter_slug}").map(&filter_slug.to_sym)
            end

            define_method "#{filter_slug}_filter_counts" do
              group(filter_slug).count
            end

            define_method "#{filter_slug}_filter_option_slug" do |option|
              option.to_s
            end

  #def self.sponsor_filter_option_name(option)
    #@sponsors ||= sponsor_filter_option_names
    #sponsor = @sponsors.detect{|sponsor| sponsor.send(sponsor_filter_value_method_name) == option}
    #sponsor.send(sponsor_filter_label_method_name)
  #end

            define_method "#{filter_slug}_filter_option_name" do |option|
              unless class_variables.include?("@@#{filter_slug}_filter_option_names")
                class_variable_set(:"@@#{filter_slug}_filter_option_names", send("#{filter_slug}_filter_option_names"))
              end
              option_names_option = class_variable_get(:"@@#{filter_slug}_filter_option_names").detect{|opt| opt.send(send("#{filter_slug}_filter_value_method_name")) == option}
              option_names_option.send(send("#{filter_slug}_filter_label_method_name"))
            end

            #define_method "#{filter_slug}_filter_option_name" do |option|
              #option.to_s.capitalize
            #end

            define_method "#{filter_slug}_filter_option_value" do |option|
              option.to_s
            end

            define_method "#{filter_slug}_filter_option_count" do |option|
              unless class_variables.include?("@@#{filter_slug}_filter_counts")
                class_variable_set(:"@@#{filter_slug}_filter_counts", send("#{filter_slug}_filter_counts"))
              end
              class_variable_get(:"@@#{filter_slug}_filter_counts")[option.to_s] || 0
            end

            define_method "#{filter_slug}_filter_option" do |option, selected|
              #[String, Integer].any?{|klass| option.kind_of?(klass)}
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
              filter_params.nil? ? true : filter_params.include?(option.to_s)
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
