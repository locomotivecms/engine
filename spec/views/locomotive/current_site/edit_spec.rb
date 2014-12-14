require 'spec_helper'

describe 'locomotive/current_site/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::SitesHelper, Locomotive::Engine.routes.url_helpers)

  let(:site)    { build('test site') }
  let(:policy)  { stub(point?: false, update_advanced?: false) }

  before do
    view.stubs(:policy).returns policy
    view.stubs(:current_locomotive_account).returns(site.memberships.first.account)
    assign(:site, site)
  end

  subject { render }

  describe 'locales' do

    it 'does not render the tab about the locales' do
      expect(subject).not_to include('Advanced')
    end

    describe 'logged as a local administrator' do

      let(:policy) { stub(point?: true, update_advanced?: true) }

      it 'renders the tab about domains' do
        expect(subject).to include('Advanced')
      end

    end

  end

  describe 'domains' do

    it 'does not render the tab about domains' do
      expect(subject).not_to include('Access points')
    end

    describe 'logged as a local administrator' do

      let(:policy) { stub(point?: true, update_advanced?: true) }

      it 'renders the placeholder text in the new domain input' do
        expect(subject).to include('Ex: mysite.com')
      end

      it 'renders the tab about domains' do
        expect(subject).to include('Access points')
      end

    end

  end

  # describe 'api_key input' do

  #   it 'displays the url to generate a new API key' do
  #     expect(subject).to include('<legend><span>API</span></legend>')
  #     expect(subject).to include('data-url="/my_account/regenerate_api_key"')
  #   end

  # end

  # describe 'file input' do

  #   it 'display a label for a new file' do
  #     expect(subject).to include('<span class="new-file hide">New file here</span>')
  #   end

  # end

  # describe 'i18n' do

  #   it 'displays a localized label' do
  #     expect(subject).to include('<label class="api_key optional control-label" for="account_api_key">API key</label>')
  #   end

  #   it 'displays a localized hint' do
  #     expect(subject).to include('Used by Wagon to deploy your site (check your config/deploy.yml file of your Wagon site).')
  #   end

  # end

end
