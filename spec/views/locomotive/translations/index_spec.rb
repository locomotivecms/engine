describe 'locomotive/translations/index', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::SitesHelper, Locomotive::Engine.routes.url_helpers)
  helper(Locomotive::TestViewHelpers)

  let(:site) { build('test site', locales: [:en, :fr]) }

  before do
    allow(view).to receive(:current_site).and_return(site)
    allow(view).to receive(:params).and_return(ActionController::Parameters.new({
      controller: 'locomotive/translations',
      action:      'index',
      site_handle: 'fluffy-marsh-2397'
    }))
    assign(:translations, Kaminari.paginate_array([create(:translation)]).page(0))
  end

  subject { render }

  it 'renders something without an exception' do
    expect { subject }.to_not raise_error
  end

end
