require 'pry'
describe Locomotive::PageContentController  do

  routes { Locomotive::Engine.routes }

  let(:site)    { create(:site,
    domains: %w{www.acme.com}) }
  let(:account) { create(:account) }
  let(:role)    { 'admin' }

  let!(:membership) do
    create(:membership,
      account: account,
    site: site, role: role)
  end

  let(:section_content) { site.sections_content }

  before do
    request_site site
    sign_in account
  end

  describe "#PUT update" do

    let(:simple_params) do
      {
        section: 'header',
        _method: 'PUT',
        page_id: site.pages.first,
        site_handle: site.handle,
        content: "{" \
          "\"header\": {" \
            "\"settings\":{" \
              "\"introduction\": \"In a hole in the ground there lived a hobbit.\"" \
            "}" \
          "}" \
        "}"
      }
    end

    subject { put :update, params: simple_params }
    it { is_expected.to eq true }
    it { expect(site.sections_content['en']['header']).to eq 'In a hole in the ground there lived a hobbit.'}
  end

end




# => <ActionController::Parameters {"_method"=>"PUT",
#   "authenticity_token"=>"FDqUZIsNztArYOKlC8K/G6OKzKNOii3mhidprZ4+lGgyW3TpkCAPgTBSovH92h9L4CUERDgSL8JhFDor6oCZSQ==",
# "section"=>"header",
# "content"=>"{\"settings\"=>{\"introduction\"=>\"In a hole in the ground there lived a hobbit.\"}}",
# "controller"=>"locomotive/page_content",
# "action"=>"update",
# "site_handle"=>"mystic-dragon",
# "page_id"=>"5af961252bf7cb7bd924353b"} permitted: false>


# => <ActionController::Parameters {"_method"=>"PUT",
#   "content"=>{"settings"=>{"introduction"=>"In a hole in the ground there lived a hobbit."}},
# "section"=>"header",
# "page_id"=>"5afbdf0c2bf7cb9c17a76b54",
# "site_handle"=>"acme",
# "controller"=>"locomotive/page_content",
# "action"=>"update"} permitted: false>
