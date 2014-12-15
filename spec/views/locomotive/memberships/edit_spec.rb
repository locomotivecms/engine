require 'spec_helper'

describe 'locomotive/memberships/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::MembershipsHelper, Locomotive::Engine.routes.url_helpers)

  let(:site)        { build('test site') }
  let(:membership)  { site.memberships.first }
  let(:policy)      { stub(change_role?: true) }

  before do
    view.stubs(:policy).returns policy
    assign(:membership, membership)
  end

  subject { render }

  it 'renders something without an exception' do
    expect { subject }.to_not raise_error
  end

end
