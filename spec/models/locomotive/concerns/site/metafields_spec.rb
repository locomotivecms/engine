require 'spec_helper'

describe Locomotive::Concerns::Site::Metafields do

  let(:schema)  { nil }
  let(:fields)  { {} }
  let(:ui)      { {} }
  let(:site)    { build(:site, metafields_schema: schema, metafields: fields, metafields_ui: ui) }

  describe 'metafields_ui=' do

    let(:ui) { '{"label":"Store settings","icon":"shopping-cart","hint":"Lorem ipsum"}' }

    subject { site.metafields_ui = ui; site.metafields_ui }

    it { is_expected.to eq('label' => 'Store settings', 'icon' => 'shopping-cart', 'hint' => 'Lorem ipsum') }

  end

  describe 'metafields_schema=' do

    let(:schema) { '[{"label":"E-commerce","fields":[]}]' }

    subject { site.metafields_schema = schema; site.metafields_schema }

    it { is_expected.to eq([{ 'label' => 'E-commerce', 'fields' => [] }]) }

  end

  describe 'schema validation' do

    subject { site.valid?; site.errors[:metafields_schema] }

    it { is_expected.to eq([]) }

    describe 'invalid schema' do

      let(:schema) { [{ :foo => {} }].as_json }
      it { is_expected.to eq(["The property '#/0' did not contain a required property of 'name'"]) }

      context 'no fields in a namespace' do

        let(:schema) { [{ 'name' => 'social_settings' }] }
        it { is_expected.to eq(["The property '#/0' did not contain a required property of 'fields'"]) }

      end

      context 'missing the name property in a field' do

        let(:schema) { [{ 'label' => 'Social', 'fields' => [{ 'label' => 'Facebook ID' }] }] }
        it { is_expected.to eq(["The property '#/0/fields/0' did not contain a required property of 'name'"]) }

      end

      context 'wrong fields types' do

        let(:schema) { [{ 'label' => 'Social', 'fields' => [{ 'name' => 'facebook_id', 'type' => 'dummy' }] }] }
        it { is_expected.to eq(["The property '#/0/fields/0/type' value \"dummy\" did not match one of the following values: string, text, integer, float, image, boolean, select, color"]) }

      end

      context 'protected field names' do

        let(:schema) { [{ 'label' => 'Social', 'fields' => [{ 'name' => 'method_missing', 'type' => 'string' }] }] }
        it { is_expected.to eq(["The property '#/0/fields/0/name' of type String matched the disallowed schema"]) }

      end

    end

    describe 'valid schema' do

      let(:schema) { [{ 'name' => 'social', 'label' => 'Social', 'fields' => [{ 'name' => 'facebook_id' }, { 'name' => 'google_id' }] }] }
      it { is_expected.to eq([]) }

    end

  end

  describe '#has_metafields?' do

    subject { site.has_metafields? }

    it { is_expected.to eq false }

    context 'with metafields' do

      let(:schema) { [{ 'name' => 'social', 'fields' => [{ 'name' => 'title' }] }] }

      it { is_expected.to eq true }

    end

  end

  describe '#any_localized_metafield?' do

    subject { site.any_localized_metafield? }

    it { is_expected.to eq false }

    context 'with non localized metafields' do

      let(:schema) { [{ 'name' => 'social', 'fields' => [{ 'name' => 'title' }] }] }

      it { is_expected.to eq false }

    end

    context 'with a localized metafield' do

      let(:schema) { [{ 'name' => 'social', 'fields' => [{ 'name' => 'title' }, { 'name' => 'body', 'localized' => true }] }] }

      it { is_expected.to eq true }

    end

  end

  describe '#find_metafield' do

    let(:name) { nil }

    subject { site.find_metafield(name) }

    it { is_expected.to eq nil }

    context 'with metafields' do

      let(:schema)  { [{ 'name' => 'social', 'fields' => [{ 'name' => 'title' }, { 'name' => 'body', 'localized' => true }] }, { 'name' => 'theme', 'fields' => [{ 'name' => 'Link Color', 'hint' => 'found it' }, { 'name' => 'background_color' }] }] }
      let(:name)    { 'link_color' }

      it { expect(subject['hint']).to eq('found it') }

    end

  end

end
