require 'active_record'

module Livelist
  module Rails

    class FilterCriterion
      attr_accessor :slug,
                    :name,
                    :count,
                    :value,
                    :type,
                    :label

      def initialize(options = {})
        @filter    = options[:filter]
        @criteria  = options[:criteria]
        @reference = options[:reference]
        @type      = infer_type
        @label     = @filter.criterion_label || infer_label
        @slug      = infer_slug
        @name      = infer_name
      end

      def selected?(params)
        params.nil? ? false : params.include?(slug.to_s)
      end

      def as_json(params)
        metadata.merge(
          :slug     => @filter.slug,
          :name     => @name,
          :value    => @slug.to_s,
          :count    => @count,
          :selected => selected?(params)
        )
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

      def infer_label
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
        when :hash   then @reference[@label]
        when :model  then @reference.send(@label)
        end
      end

      def property_value(property)
        case @type
        when :scalar then nil
        when :hash   then @reference[property]
        when :model  then @reference.send(property)
        end
      end

      def metadata
        @criteria.metadata_properties.reduce({}) do |result, property|
          result[property] = property_value(property)
          result
        end
      end
    end

  end
end
