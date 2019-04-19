module Locomotive
  describe ContentEntryImpersonationsController do

    routes { Locomotive::Engine.routes }

    let(:site)     { content_entry.site }
    let(:account)  { create(:account) }
    let!(:membership) do
      create(:membership, account: account, site: site, role: 'admin')
    end
    let(:content_type) do
      create('account content type').tap do |content_type|
        content_type.entries.create(name: 'John Doe', email: 'john@doe.net', password: 'easyone')
      end
    end
    let(:content_entry) { content_type.entries.first }

    before do
      request_site site
      sign_in account
    end

    describe "#POST create" do
      subject do
        post :create, params: { site_handle: site, locale: :en, slug: content_type.slug, content_entry_id: content_entry._id.to_s }
      end

      it { is_expected.to redirect_to('/locomotive/acme/preview') }
      it { subject; expect(session[:authenticated_impersonation]).to eq '1' }
      it { subject; expect(session[:authenticated_entry_id]).to eq content_entry._id.to_s }
      it { subject; expect(session[:authenticated_entry_type]).to eq 'accounts' }

      context 'the context type has not been set up for authentication' do
        let(:content_type) do
          create('photo content type').tap do |content_type|
            content_type.entries.create(title: 'My photo')
          end
        end
        it { is_expected.to redirect_to('/locomotive/acme/content_types/photos/entries') }
      end
    end

  end
end
