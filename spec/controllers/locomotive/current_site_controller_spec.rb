describe Locomotive::CurrentSiteController do

  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end

  before do
    request_site site
    sign_in account
  end

  describe "#GET edit" do
    subject { get :edit, params: { site_handle: site, locale: :en } }
    it { is_expected.to be_successful }
    specify do
      subject
      expect(assigns(:site)).to be_present
    end
  end

  describe "#PUT update" do

    let(:attributes) { { name: 'foooo' } }

    subject do
      put :update, params: { site_handle: site, locale: :en, site: attributes }
    end

    it { is_expected.to be_redirect }

    specify do
      subject
      expect(assigns(:site).name).to eq('foooo')
    end

    describe 'update url redirections from plain text' do

      let(:attributes) { { url_redirections_expert_mode: expert_mode, url_redirections_plain_text: '/en/foo /en/bar' } }

      context 'not in expert mode' do

        let(:expert_mode) { '0' }

        it "doesn't update the url redirections from the plain text" do
          subject
          expect(assigns(:site).url_redirections.size).to eq(0)
        end

      end

      context 'in expert mode' do

        let(:expert_mode) { '1' }

        it "updates the url redirections from the plain text" do
          subject
          expect(assigns(:site).url_redirections.size).to eq(1)
        end

      end

    end

  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, params: { site_handle: site, locale: :en }
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::Site, :count).by(-1)
    end
  end

end
