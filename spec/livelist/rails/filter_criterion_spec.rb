require 'spec_helper.rb'
require File.expand_path('./lib/livelist/rails/filter_criterion.rb')

describe Livelist::Rails::FilterCriterion do

  let(:filter) { double(:filter, :criterion_label => nil) }
  let(:criteria) { double(:criteria, :slug => :name) }
  let(:reference) { {} }

  subject do
    Livelist::Rails::FilterCriterion.new(
      :filter => filter,
      :criteria => criteria,
      :reference => reference
    )
  end

	context :initialize do
    its(:label) { should_not be_nil }

    context 'when criterion_label is set on the filter' do
      let(:filter) { double(:filter, :criterion_label => :label) }
      its(:label) { should == :label }
    end
	end

	context :selected? do

	end

	context :as_json do

	end

	context :infer_type do

	end

	context :infer_name_key do

	end

	context :infer_slug do

	end

	context :infer_name do

	end
end
