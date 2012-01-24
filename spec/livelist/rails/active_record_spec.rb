require 'spec_helper.rb'
require File.expand_path('./lib/livelist/rails/active_record.rb')

describe Livelist::Rails::ActiveRecord do
  class User
    extend Livelist::Rails::ActiveRecord
    filters :status, :state
  end

	subject { User }

	context :filter_name do
		it { subject.should respond_to(:state_filter_name) }
		it { subject.should respond_to(:status_filter_name) }
	end
end
