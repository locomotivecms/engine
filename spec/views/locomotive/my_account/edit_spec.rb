require 'spec_helper'

describe 'locomotive/my_account/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::Shared::AccountsHelper, Locomotive::MyAccountHelper, Locomotive::Engine.routes.url_helpers)

  let(:account) { build(:account, api_key: 42) }

  before {
    allow(view).to receive(:last_saved_location).and_return(nil)
    allow(view).to receive(:current_locomotive_account).and_return(account)
  }

  before do
    assign(:account, account)
  end

  subject { render }

  describe 'api_key input' do

    it 'renders the url to generate a new API key' do
      expect(subject).to include('<legend><span>api</span></legend>')
      expect(subject).to include('data-url="/my_account/regenerate_api_key"')
    end

  end

  describe 'file input' do

    it 'renders a label for a new file' do
      expect(subject).to include('<span class="file-name">no file</span>')
    end

  end

  describe 'i18n' do

    it 'renders a localized label' do
      expect(subject).to include('<label class="api_key optional control-label" for="account_api_key">API key</label>')
    end

    it 'renders a localized hint' do
      expect(subject).to include('Used by Wagon to deploy your site (check your config/deploy.yml file of your Wagon site).')
    end

  end

end
