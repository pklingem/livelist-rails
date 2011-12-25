require 'active_record'

module Livelist
  module Rails
    module ActiveRecord

      def filters(*filter_slugs)
        @@filter_slugs = filter_slugs
        @@filter_slugs.each do |filter_slug|
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

            define_method "#{filter_slug}_filter_options" do
              select("distinct #{filter_slug}").map(&filter_slug)
            end

            define_method "#{filter_slug}_filter_counts" do
              group(filter_slug).count
            end

            define_method "#{filter_slug}_filter_option" do |state, selected|
              {
                :slug => state,
                :name => state.capitalize,
                :value => state,
                :count => @counts[state],
                :selected => selected
              }
            end

            define_method "#{filter_slug}_filters" do |filter_params|
              @counts = send("#{filter_slug}_filter_counts")
              send("#{filter_slug}_filter_options").map do |option|
                selected = filter_params.nil? ? true : filter_params.include?(option)
                send("#{filter_slug}_filter_option", option, selected)
              end
            end

            define_method "#{filter_slug}_relation" do |values|
              where(filter_slug => values)
            end
          end
        end

        def self.filters_as_json(filter_params)
          filter_params ||= {}
          @@filter_slugs.map do |filter|
            send("#{filter}_filter", send("#{filter}_filters", filter_params[filter]))
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
