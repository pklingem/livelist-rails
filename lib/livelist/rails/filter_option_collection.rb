require 'livelist/rails/filter_option'

class FilterOptionCollection < HashWithIndifferentAccess
	alias :options :values
	alias :find_option :[]

	def initialize(options)
		@filter     = options[:filter]
		@collection = options[:collection] || default_collection
		@collection = @collection.call if @collection.respond_to?(:call)
		@slug       = options[:slug]

		@collection.each do |option|
			create_option(:filter => @filter, :slug => option[@slug], :name => option[:name])
		end
	end

	def default_collection
		lambda { select("distinct #{@filter.slug}") }
	end

	def create_option(options)
		self[options[:slug]] = FilterOption.new(options)	
	end

	def slugs
		options.map(&:slug)
	end

	def counts=(counts_hash)
		options.each do |option|
			option.count = counts_hash[option.slug.to_s] || 0
		end
	end
end
