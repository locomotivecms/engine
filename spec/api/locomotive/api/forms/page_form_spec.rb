require 'spec_helper'

describe Locomotive::API::Forms::PageForm do

  let(:attributes) { { title: 'Home page' } }
  let(:form) { described_class.new(attributes) }

  describe '#serializable_hash' do

    subject { form.serializable_hash }

    it { is_expected.to eq('title' => 'Home page') }

    describe 'redirect' do

      let(:attributes) { { title: 'Home page', redirect_url: 'http://www.apple.com' } }

      it { is_expected.to eq('title' => 'Home page', 'redirect' => true, 'redirect_url' => 'http://www.apple.com') }

    end

  end

end
