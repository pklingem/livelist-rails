require 'livelist/rails/filter'

class FilterCollection < HashWithIndifferentAccess
	alias :filters :values
	alias :find_filter :[]

	def create_filter(options)
    options.merge!(:filter_collection => self)
		self[options[:slug]] = Livelist::Rails::Filter.new(options)
	end

  def relation(filter_params, query)
    filters.each do |filter|
      default_filter_values = filter.values
      params_filter_values = filter_params[filter.slug.to_s]
      query = query.includes(filter.join) if filter.type == :association
      query = query.where(filter.where(default_filter_values))
      query = query.where(filter.where(params_filter_values)) unless filter_params.empty?
    end
    query
  end
end
