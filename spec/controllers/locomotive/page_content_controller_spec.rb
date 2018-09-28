describe Locomotive::PageContentController  do

  routes { Locomotive::Engine.routes }

  let(:site)    { create(:site, domains: %w{www.acme.com}) }
  let(:account) { create(:account) }
  let(:role)    { 'admin' }

  let!(:membership) { create(:membership, account: account, site: site, role: role) }
  let!(:section)    { create(:section, site: site) }

  let(:section_content) { site.sections_content }

  before do
    request_site site
    sign_in account
  end

  describe "#PUT update" do
    let(:simple_params) do
      {
        _method: 'PUT',
        page_id: site.pages.first,
        site_handle: site.handle,
        page: {
          sections_dropzone_content: <<-JSON
            []
          JSON
        },
        site: {
          sections_content: <<-JSON
            {
              "header":
                {
                  "settings":{
                    "title": "Locomotive Sections System !"
                  },
                  "blocks": []
                }
            }
          JSON
        },
      }
    end

    subject { put :update, params: simple_params, format: :json }

    it 'should update global site sections' do
      is_expected.to have_http_status :success
      expect(site.sections_content['header']['settings']['title']).to eq 'Locomotive Sections System !'
    end
  end
end
