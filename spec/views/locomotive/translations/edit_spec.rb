describe 'locomotive/translations/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::SitesHelper, Locomotive::Engine.routes.url_helpers)
  helper(Locomotive::TestViewHelpers)

  let(:site)        { build('test site', locales: [:en, :fr]) }
  let(:translation) { create(:translation) }
  let(:nav)         { { filter_by: 'untranslated', q: 'hell' } }

  before do
    allow(view).to receive(:current_site).and_return(site)
    allow(view).to receive(:translation_nav_params).and_return(nav)
    assign(:translation, translation)
  end

  subject { render }

  it 'renders something without an exception' do
    expect {
      expect(subject).to include(%(<a href="/locomotive/test/translations?filter_by=untranslated&amp;q=hell">))
    }.to_not raise_error
  end

end
