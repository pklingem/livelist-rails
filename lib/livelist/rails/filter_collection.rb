require 'livelist/rails/filter'

class FilterCollection < HashWithIndifferentAccess
	alias :filters :values
	alias :find_filter :[]

	def create_filter(options)
    options.merge!(:filter_collection => self)
		self[options[:slug]] = Livelist::Rails::Filter.new(options)
	end

  def relation(query, params)
    params ||= {}
    filters.each { |filter| filter.relation(query, params) }
    query
  end

  def as_json(query, params)
    params ||= {}
    filters.map do |filter|
      filter.set_option_counts(query, params)
      filter.as_json(params[filter.slug])
    end
  end
end
