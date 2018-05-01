describe 'locomotive/memberships/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::MembershipsHelper, Locomotive::Engine.routes.url_helpers)
  helper(Locomotive::TestViewHelpers)

  let(:site)        { create('test site') }
  let(:membership)  { site.memberships.first }
  let(:_policy)     { instance_double('policy', change_role?: true) }

  before do
    allow(view).to receive(:current_site).and_return(site)
    allow(view).to receive(:policy).and_return(_policy)
    assign(:membership, membership)
  end

  subject { render }

  it 'renders something without an exception' do
    expect { subject }.to_not raise_error
  end

end
