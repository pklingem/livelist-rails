class FilterOption
	attr_accessor :slug, :name, :count

	def initialize(options = {})
		@slug = options[:slug]
		@name = options[:name]
	end
end
