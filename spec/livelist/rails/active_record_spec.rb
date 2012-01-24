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

	context :filter_slug do
		it { subject.should respond_to(:state_filter_slug) }
		it { subject.should respond_to(:status_filter_slug) }
	end

	context :filter do
		it { subject.should respond_to(:state_filter) }
		it { subject.should respond_to(:status_filter) }
	end

	context :filter_values do
		it { subject.should respond_to(:state_filter_values) }
		it { subject.should respond_to(:status_filter_values) }
	end

	context :filter_counts do
		it { subject.should respond_to(:state_filter_counts) }
		it { subject.should respond_to(:status_filter_counts) }
	end

	context :filter_option_slug do
		it { subject.should respond_to(:state_filter_option_slug) }
		it { subject.should respond_to(:status_filter_option_slug) }
	end

	context :filter_option_name do
		it { subject.should respond_to(:state_filter_option_name) }
		it { subject.should respond_to(:status_filter_option_name) }
	end

	context :filter_option_count do
		it { subject.should respond_to(:state_filter_option_count) }
		it { subject.should respond_to(:status_filter_option_count) }
	end

	context :filter_option do
		it { subject.should respond_to(:state_filter_option) }
		it { subject.should respond_to(:status_filter_option) }
	end

	context :filter_option_selected? do
		it { subject.should respond_to(:state_filter_option_selected?) }
		it { subject.should respond_to(:status_filter_option_selected?) }
	end

	context :filters do
		it { subject.should respond_to(:state_filters) }
		it { subject.should respond_to(:status_filters) }
	end

	context :relation do
		it { subject.should respond_to(:state_relation) }
		it { subject.should respond_to(:status_relation) }
	end

	context :filters_as_json do
		it { subject.should respond_to(:filters_as_json) }
	end

	context :filter do
		it { subject.should respond_to(:filter) }
	end

end
