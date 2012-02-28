require 'livelist/rails/filter'

class FilterCollection < HashWithIndifferentAccess
	alias :filters :values
	alias :find_filter :[]
	alias :slugs :keys

	def create_filter(options)
		self[options[:slug]] = Livelist::Rails::Filter.new(options)
	end
end
