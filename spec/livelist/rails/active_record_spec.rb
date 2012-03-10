require 'spec_helper.rb'
require File.expand_path('./lib/livelist/rails/active_record.rb')

describe Livelist::Rails::ActiveRecord do
  class User
    extend Livelist::Rails::ActiveRecord
    filters :status, :state
  end

	subject { User }

	context :filter_for do

	end

	context :filters_as_json do

	end

	context :filter do

	end
end
