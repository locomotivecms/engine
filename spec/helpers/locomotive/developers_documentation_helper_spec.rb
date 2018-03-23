require 'spec_helper'

module Locomotive
  describe DevelopersDocumentationHelper do
    describe '#developer_documentation_wagon_clone_string' do
      let(:current_site) { create(:site) }
      let(:current_locomotive_account) { create(:account, api_key: 'abc', email: 'foo@bar.com') }
      let(:expected_wagon_string) do
        "wagon clone acme_website http://test.host -h acme -e foo@bar.com -a abc"
      end

      around do |ex|
        without_partial_double_verification { ex.run }
      end

      before do
        allow(helper).to receive(:current_site).and_return(current_site)
        allow(helper).to receive(:current_locomotive_account).and_return(current_locomotive_account)
      end

      subject { helper.developer_documentation_wagon_clone_string }
      it { is_expected.to eq expected_wagon_string }

    end

  end

end
