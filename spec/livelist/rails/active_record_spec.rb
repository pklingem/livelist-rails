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

    it { subject.state_filter_name.should == 'State' }
	end

	context :filter_slug do
		it { subject.should respond_to(:state_filter_slug) }
		it { subject.should respond_to(:status_filter_slug) }

    it { subject.state_filter_slug.should == 'state' }
	end

	context :filter do
    let(:options) do
      [{
        :slug => 'virginia',
        :name => 'Virginia',
        :value => 'virginia',
        :count => 1,
        :selected => true
      }]
    end

		it { subject.should respond_to(:state_filter) }
		it { subject.should respond_to(:status_filter) }

    it 'should be a hash with the proper keys/values' do
      subject.should_receive(:state_filter_slug).and_return('state')
      subject.should_receive(:state_filter_name).and_return('State')
      subject.state_filter(options).should == {
        :filter_slug => 'state',
        :name => 'State',
        :options => options
      }
    end
	end

	context :filter_values do
    let(:values) do
      [
        double('Object', :state => 'Virginia'),
        double('Object', :state => 'South Carolina')
      ]
    end

		it { subject.should respond_to(:state_filter_values) }
		it { subject.should respond_to(:status_filter_values) }

    it 'should return a mapped list of values' do
      subject.should_receive(:select).and_return(values)
      subject.state_filter_values.should == ['Virginia', 'South Carolina']
    end
	end

	context :filter_counts do
		it { subject.should respond_to(:state_filter_counts) }
		it { subject.should respond_to(:status_filter_counts) }

    it 'should be tested' do
      pending
    end
	end

	context :filter_option_slug do
    let(:option) { 'virginia' }

		it { subject.should respond_to(:state_filter_option_slug) }
		it { subject.should respond_to(:status_filter_option_slug) }

    it { subject.state_filter_option_slug(option).should == 'virginia' }
	end

	context :filter_option_name do
    let(:option) { 'virginia' }

		it { subject.should respond_to(:state_filter_option_name) }
		it { subject.should respond_to(:status_filter_option_name) }

    it { subject.state_filter_option_name(option).should == 'Virginia' }
	end

	context :filter_option_value do
    let(:option) { 'virginia' }

		it { subject.should respond_to(:state_filter_option_count) }
		it { subject.should respond_to(:status_filter_option_count) }

    it { subject.state_filter_option_value(option).should == 'virginia' }
	end

	context :filter_option_count do
    let(:option) { 'Virginia' }
    let(:state_filter_counts) { { 'Virginia' => 1, 'South Carolina' => 2 } }

		it { subject.should respond_to(:state_filter_option_count) }
		it { subject.should respond_to(:status_filter_option_count) }

    it 'option argument should be converted to a string' do
      state_filter_counts['1'] = 3
      subject.should_receive(:state_filter_counts).and_return(state_filter_counts)
      subject.state_filter_option_count(1).should == 3
    end

    it 'should be the proper count for the option' do
      subject.should_receive(:state_filter_counts).and_return(state_filter_counts)
      subject.state_filter_option_count(option).should == 1
    end

    it 'should be 0 if the value for the option is nil' do
      subject.should_receive(:state_filter_counts).and_return(state_filter_counts)
      subject.state_filter_option_count('West Virginia').should == 0
    end

    it 'should cache the counts when the method is first called' do
      pending
      #subject.should_receive(:state_filter_counts).exactly(1).times.and_return(state_filter_counts)
      #subject.state_filter_option_count(option)
      #subject.state_filter_option_count('South Carolina')
    end
	end

	context :filter_option do
    let(:option) { 'virginia' }
    let(:selected) { true }

		it { subject.should respond_to(:state_filter_option) }
		it { subject.should respond_to(:status_filter_option) }

    it 'should be a properly formatted hash' do
      subject.should_receive(:state_filter_option_slug).and_return('virginia')
      subject.should_receive(:state_filter_option_name).and_return('Virginia')
      subject.should_receive(:state_filter_option_value).and_return('virginia')
      subject.should_receive(:state_filter_option_count).and_return(1)
      subject.state_filter_option(option, selected).should == {
        :slug => 'virginia',
        :name => 'Virginia',
        :value => 'virginia',
        :count => 1,
        :selected => true
      }
    end
	end

	context :filter_option_selected? do
    let(:option) { 'Virginia' }
    let(:filter_params) { ['Virginia', 'South Carolina'] }

		it { subject.should respond_to(:state_filter_option_selected?) }
		it { subject.should respond_to(:status_filter_option_selected?) }

    it 'should be true if the option is included in the filter params' do
      subject.state_filter_option_selected?(filter_params, option).should be_true
    end

    it 'should be true if filter params is nil' do
      subject.state_filter_option_selected?(nil, option).should be_true
    end

    it 'should be false if the option is not included in the filter params' do
      subject.state_filter_option_selected?(['West Virginia'], option).should be_false
    end
	end

	context :filters do
		it { subject.should respond_to(:state_filters) }
		it { subject.should respond_to(:status_filters) }

    it 'should be tested' do
      pending
    end
	end

	context :relation do
		it { subject.should respond_to(:state_relation) }
		it { subject.should respond_to(:status_relation) }

    it 'should be tested' do
      pending
    end
	end

	context :filters_as_json do
		it { subject.should respond_to(:filters_as_json) }

    it 'should be tested' do
      pending
    end
	end

	context :filter do
		it { subject.should respond_to(:filter) }

    it 'should be tested' do
      pending
    end
	end

end
