class FilterOption
	attr_accessor :slug, :name, :count, :value

	def initialize(options = {})
		@slug   = options[:slug]
		@name   = options[:name]
		@filter = options[:filter]
	end

	def selected?(params)
		params.nil? ? false : params.include?(slug.to_s)
	end

	def as_json(params)
		{
			:slug     => @filter.slug,
			:name     => @filter.name,
			:value    => @slug.to_s,
			:count    => @count,
			:selected => selected?(params)
		}
	end
end
