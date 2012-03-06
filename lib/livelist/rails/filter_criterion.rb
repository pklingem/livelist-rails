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
        @filter    = options[:filter]
        @criteria  = options[:criteria]
        @reference = options[:reference]
        @type      = infer_type
        @name_key  = options[:name_key] || infer_name_key
        @slug      = infer_slug
        @name      = infer_name
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

      def infer_type
        raise ArgumentError, "reference is not valid \n #{@reference.inspect}" if @reference.nil?
        if [String, Symbol, Integer].any?{|klass| @reference.kind_of?(klass)}
          :scalar
        elsif @reference.kind_of?(Hash)
          :hash
        else
          :model
        end
      end

      def infer_name_key
        case @type
        when :scalar then nil
        when :hash then :name
        when :model
          if @reference.respond_to?(:name)
            :name
          elsif @reference.respond_to?(@criteria.slug)
            @criteria.slug
          end
        end
      end

      def infer_slug
        case @type
        when :scalar       then @reference
        when :hash, :model then @reference[@criteria.slug]
        end
      end

      def infer_name
        case @type
        when :scalar then @reference
        when :hash   then @reference[@name_key]
        when :model  then @reference.send(@name_key)
        end
      end
    end

  end
end
