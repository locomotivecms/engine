require 'spec_helper'

describe 'locomotive/memberships/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::MembershipsHelper, Locomotive::Engine.routes.url_helpers)

  let(:site)        { create('test site') }
  let(:membership)  { site.memberships.first }
  let(:policy)      { instance_double('policy', change_role?: true) }

  before do
    allow(view).to receive(:current_site).and_return(site)
    allow(view).to receive(:policy).and_return(policy)
    assign(:membership, membership)
  end

  subject { render }

  it 'renders something without an exception' do
    expect { subject }.to_not raise_error
  end

end
