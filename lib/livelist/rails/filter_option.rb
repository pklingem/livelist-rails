module Livelist
  module Rails

    class FilterOption
      attr_accessor :slug, :name, :count, :value

      def initialize(options = {})
        @option_collection = options[:option_collection]
        @slug              = slug_param(options[:option])
        @name              = name_param(options[:option])
        @filter            = options[:filter]
      end

      def name_param(option)
        if [String, Symbol, Integer].any?{|klass| option.kind_of?(klass)}
          option
        elsif option.kind_of?(Hash) && option.has_key?(:name)
          option[:name]
        elsif option.respond_to?(:name)
          option.name
        else
         option[@option_collection.slug]
        end
      end

      def slug_param(option)
        if [String, Symbol, Integer].any?{|klass| option.kind_of?(klass)}
          option
        else
          option[@option_collection.slug]
        end
      end

      def selected?(params)
        params.nil? ? false : params.include?(slug.to_s)
      end

      def as_json(params)
        {
          :slug     => @filter.slug,
          :name     => @name,
          :value    => @slug.to_s,
          :count    => @count,
          :selected => selected?(params)
        }
      end
    end

  end
end
