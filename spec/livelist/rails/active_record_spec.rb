require 'spec_helper.rb'
require 'active_support/core_ext/string/inflections'
require File.expand_path('./lib/livelist/rails/active_record.rb')

describe Livelist::Rails::ActiveRecord do
  module ActiveRecord::ClassMethods
		def model_name
			'User'
		end

		def column_names
			['state', 'status']
		end

		def reflect_on_all_associations
			[]
		end

		def select(*args)
			[]
		end
  end

  class User
    extend ActiveRecord::ClassMethods
    extend Livelist::Rails::ActiveRecord

    filter_for :status
		filter_for :state
  end

	subject { User.new }

	context :filter_for do
    it 'should set filters instance variable to a filter collection object' do
      User.filters.should be_kind_of(Livelist::Rails::FilterCollection)
    end
	end

	context :filters_as_json do

	end

	context :filter do

	end
end
