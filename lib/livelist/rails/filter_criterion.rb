require 'active_record'

module Livelist
  module Rails

    class FilterCriterion
      attr_accessor :slug,
                    :name,
                    :count,
                    :value,
                    :type,
                    :name_key

      def initialize(options = {})
        @filter            = options[:filter]
        @option_collection = options[:option_collection]
        @type              = infer_type(options[:option])
        @name_key          = options[:name_key] || infer_name_key(options[:option])
        @slug              = infer_slug(options[:option])
        @name              = infer_name(options[:option])
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

    private

      def infer_type(option)
        raise ArgumentError, "option is not valid \n #{option.inspect}" if option.nil?
        if [String, Symbol, Integer].any?{|klass| option.kind_of?(klass)}
          :scalar
        elsif option.kind_of?(Hash)
          :hash
        else
          :model
        end
      end

      def infer_name_key(option)
        case @type
        when :scalar then nil
        when :hash then :name
        when :model
          if option.respond_to?(:name)
            :name
          elsif option.respond_to?(@option_collection.slug)
            @option_collection.slug
          end
        end
      end

      def infer_slug(option)
        case @type
        when :scalar       then option
        when :hash, :model then option[@option_collection.slug]
        end
      end

      def infer_name(option)
        case @type
        when :scalar then option
        when :hash   then option[@name_key]
        when :model  then option.send(@name_key)
        end
      end
    end

  end
end
