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

  end

end
