class FilterOption
	attr_accessor :slug, :name, :count, :value

	def initialize(options = {})
		@slug = options[:slug]
		@name = options[:name]
	end

	def selected?(params)
		params.nil? ? false : params.include?(slug.to_s)
	end
end
