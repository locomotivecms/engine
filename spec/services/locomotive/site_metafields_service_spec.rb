# encoding: utf-8

describe Locomotive::SiteMetafieldsService do

  let(:values)  { { 'theme' => { 'background_color' => '#000', 'background_image' => '/samples/banner.jpg' } } }
  let(:schema)  { [{ 'name' => 'theme', 'fields' => [{ 'name' => 'background_color' }, { 'name' => 'background_image' }] }] }
  let(:site)    { create(:site, metafields_schema: schema, metafields: values) }
  let(:account) { create(:account) }
  let(:service) { described_class.new(site, account) }

  describe '#update_all' do

    let(:attributes) { { 'theme' => { 'background_color' => '#f00', 'background_image' => '/samples/banner.jpg' } } }

    subject { service.update_all(attributes); site.reload }

    context 'no attributes passed to the controller' do

      let(:attributes)  { nil }

      it { expect(subject.metafields['theme']['background_color']).to eq '#000' }

    end

    context 'no initial values' do

      let(:values) { {} }

      it { expect(site.metafields['theme']).to eq nil }
      it { expect(subject.metafields['theme']['background_color']).to eq '#f00' }

    end

    context 'with initial values' do

      it { expect(subject.metafields['theme']['background_color']).to eq '#f00' }

    end

    context 'with localized value' do

      before { allow(::Mongoid::Fields::I18n).to receive(:locale).and_return(:fr) }

      let(:values)      { { 'shop' => { 'street' => { 'en' => '7 alley Albert Camus' } } } }
      let(:schema)      { [{ 'name' => 'shop', 'fields' => [{ 'name' => 'street', 'localized' => true }] }] }
      let(:attributes)  { { 'shop' => { 'street' => '7 allée Albert Camus' } } }

      it { expect(subject.metafields['shop']['street']).to eq('fr' => '7 allée Albert Camus', 'en' => '7 alley Albert Camus') }

    end

    context 'unknown attribute names' do

      let(:attributes) { { 'theme' => { 'icon' => '/samples/icon.jpg' }, 'misc' => { 'text' => 'hello world' } } }

      it { expect(subject.metafields['theme']['icon']).to eq nil }
      it { expect(subject.metafields['misc']).to eq({}) }

    end

    context 'field name shared across namespaces with different localization' do

      before { allow(::Mongoid::Fields::I18n).to receive(:locale).and_return(:en) }

      let(:values) { {} }
      let(:schema) do
        [
          { 'name' => 'contacts',        'fields' => [{ 'name' => 'address', 'localized' => true }] },
          { 'name' => 'mailer_settings', 'fields' => [{ 'name' => 'address' }] }
        ]
      end

      let(:attributes) do
        {
          'contacts'        => { 'address' => '7 alley Albert Camus' },
          'mailer_settings' => { 'address' => 'smtp.example.org' }
        }
      end

      it 'localizes the value in the namespace whose field is localized' do
        expect(subject.metafields['contacts']['address']).to eq('en' => '7 alley Albert Camus')
      end

      it 'keeps the value plain in the namespace whose field is not localized' do
        expect(subject.metafields['mailer_settings']['address']).to eq 'smtp.example.org'
      end

    end

    context 'namespace name requiring normalization (uppercase)' do

      let(:values) { {} }
      let(:schema) do
        [{ 'name' => 'Mailer_Settings', 'fields' => [{ 'name' => 'address' }] }]
      end
      # the backoffice form posts the normalized namespace key (dom_id)
      let(:attributes) { { 'mailer_settings' => { 'address' => 'smtp.example.org' } } }

      it 'still resolves the schema and persists the value' do
        expect(subject.metafields['mailer_settings']['address']).to eq 'smtp.example.org'
      end

    end

  end

end
