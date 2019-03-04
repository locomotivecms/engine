describe 'locomotive/current_site_metafields/index', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::Shared::AccountsHelper, Locomotive::Shared::SitesHelper, Locomotive::Shared::SiteMetafieldsHelper, Locomotive::CurrentSiteMetafieldsHelper, Locomotive::Engine.routes.url_helpers)
  helper(Locomotive::TestViewHelpers)

  let(:schema)  { [] }
  let(:site)    { create('test site', metafields_schema: schema) }

  before do
    allow(view).to receive(:current_site).and_return(site)
    allow(view).to receive(:current_locomotive_account).and_return(site.memberships.first.account)
    assign(:site, site)
  end

  subject { render }

  describe 'no metafields schema' do

    it 'does not render the tab about the locales' do
      expect(subject).to include('There are no metafields defined for your site.')
    end

  end

  describe 'namespace' do

    let(:schema) { [
      { 'name' => 'theme', 'fields' => [{ 'name' => 'background_color'}], 'position' => 1 },
      { 'name' => 'shop', 'label' => 'My shop', 'fields' => [{ 'name' => 'address'}], 'position' => 0 }
    ] }

    it 'renders the tabs with namespaces' do
      expect(subject).to include('My shop')
      expect(subject).to include('Theme')
      expect(subject.index('My shop')).to be < subject.index('Theme')
    end

  end

  describe 'fields' do

    let(:schema) { [
      { 'name' => 'shop', 'label' => 'My shop', 'fields' => [
        { 'name' => 'address', 'hint' => 'My address goes here' }, { 'name' => 'city', 'label' => 'My city' }, { 'name' => 'zip_code' }, { 'name' => 'icon', 'type' => 'image' }
      ], 'position' => 0 } ] }

    it 'renders the fields' do
      expect(subject).to include('>Address</label>')
      expect(subject).to include('>My city</label>')
      expect(subject).to include('>Zip code</label>')
      expect(subject).to include('>My address goes here</span>')
    end

    describe 'select field type' do

      let(:schema) { [
        { 'name' => 'theme', 'fields' => [
          { 'name' => 'color', 'type' => 'select', 'select_options' => { 'blue' => { 'en' => 'Blue color' }, 'red' => { 'en' => 'Red color' } } }
        ] }] }

      it 'renders the options' do
        expect(subject).to include('<option value="blue">Blue color</option>')
        expect(subject).to include('<option value="red">Red color</option>')
      end

    end

  end

end
