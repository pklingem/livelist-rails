require 'spec_helper.rb'
require File.expand_path('./lib/livelist/rails/filter.rb')

describe Livelist::Rails::Filter do

  class MyModel; end

  let(:options) do
    {
      :slug => :my_filter,
      :model_name => :my_model
    }
  end
  subject { Livelist::Rails::Filter.new(options) }

	context :initialize do

    its(:criterion_label) { should be_nil }

    context 'when criterion_label option is set' do
      before { options[:criterion_label] = :label }
      its(:criterion_label) { should == :label }
    end

    context 'when slug option is not set' do
      subject { Livelist::Rails::Filter.new }
      it { -> { subject }.should raise_error ArgumentError, 'slug option required' }
    end

    context 'when model_name option is not set' do
      subject { Livelist::Rails::Filter.new(:slug => :my_filter) }
      it { -> { subject }.should raise_error ArgumentError, 'model_name option required' }
    end

	end

  context :group_by do

  end

  context :exclude_filter_relation? do

  end

  context :set_criteria_counts do

  end

  context :relation do

  end

  context :counts do

  end

  context :table_name do

  end

  context :model_class do

  end

  context :where do

  end

  context :as_json do

  end

  context :default_key_name do

  end

  context :initialize_type do

  end
end
