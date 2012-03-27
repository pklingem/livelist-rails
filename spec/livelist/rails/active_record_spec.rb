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

    def scoped
      ActiveRecord::Relation.new(nil, nil)
    end
  end

  class User
    extend ActiveRecord::ClassMethods
    extend Livelist::Rails::ActiveRecord
  end

	subject { User }

	context :filters do
    it 'filters should be a FilterCollection object' do
      subject.filters.should be_kind_of(Livelist::Rails::FilterCollection)
    end
	end

  context :filter_for do
    let(:name) { 'State' }
    let(:reference_criteria) { ['South Carolina', 'Virginia'] }
    let(:options) do
      {
        :reference_criteria => reference_criteria,
        :name               => name,
        :model_name         => 'User',
        :slug               => :state
      }
    end

    it 'should call create a filter with the proper options' do
      subject.filters.should_receive(:create_filter).with(options)
      subject.filter_for(:state, :reference_criteria => reference_criteria, :name => name)
    end
  end

  context 'Runtime Methods' do
    let(:options) do
      {}
    end

    let(:params) do
      {}
    end

    context :filters_as_json do
      it do
        subject.filters.should_receive(:as_json).with(nil, params, options)
        subject.filters_as_json(params, options)
      end
    end

    context :filter do
      it do
        subject.filters.should_receive(:filter).with(nil, params, options)
        subject.filter(params, options)
      end
    end
  end
end
