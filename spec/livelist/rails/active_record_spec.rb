require 'spec_helper.rb'
require File.expand_path('./lib/livelist/rails/active_record.rb')

describe Livelist::Rails::ActiveRecord do
  #class User
  #  extend Livelist::Rails::ActiveRecord

	#	def self.model_name
	#		'User'
	#	end

  #  filter_for :status
	#	filter_for :state
  #end

	subject { User.new }

	context :filter_for do

	end

	context :filters_as_json do

	end

	context :filter do

	end
end
