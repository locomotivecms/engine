describe 'locomotive/current_site/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::Shared::AccountsHelper, Locomotive::Shared::SitesHelper, Locomotive::SitesHelper, Locomotive::Engine.routes.url_helpers)
  helper(Locomotive::TestViewHelpers)

  let(:site)    { create('test site') }
  let(:_policy)  { instance_double('policy', create?: false, point?: false, update_advanced?: false, destroy?: false) }

  before do
    allow(view).to receive(:current_site).and_return(site)
    allow(view).to receive(:policy).and_return(_policy)
    allow(view).to receive(:current_locomotive_account).and_return(site.memberships.first.account)
    assign(:site, site)
  end

  subject { render }

  describe 'locales' do

    it 'does not render the tab about the locales' do
      expect(subject).not_to include('Advanced')
    end

    describe 'logged as a local administrator' do

      let(:_policy) { instance_double('policy', create?: true, point?: true, update_advanced?: true, destroy?: false) }

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

      let(:_policy) { instance_double('policy', create?: true, point?: true, update_advanced?: true, destroy?: false) }

      it 'renders the placeholder text in the new domain input' do
        expect(subject).to include('Ex: mysite.com')
      end

      it 'renders the tab about domains' do
        expect(subject).to include('Access points')
      end

    end

  end

end
