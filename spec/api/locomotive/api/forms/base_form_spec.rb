require 'spec_helper'

describe Locomotive::API::Forms::BaseForm do
  describe '.attributes' do
    subject { described_class.attributes }
    class Locomotive::API::Forms::BaseFormSubclass < Locomotive::API::Forms::BaseForm
      @attributes = [:foo]
    end

    subject { Locomotive::API::Forms::BaseFormSubclass.attributes }

    it { is_expected.to include (:foo) }
  end

  describe '#persisted?' do
    subject { described_class.new.persisted? }
    it { is_expected.to be_falsey }

  end
end
