require 'spec_helper'

describe Locomotive::Concerns::Site::Metafields do

  let(:schema)  { nil }
  let(:fields)  { {} }
  let(:site)    { build(:site, metafields_schema: schema, metafields: fields) }

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
      it { is_expected.to eq(["The property '#/0' did not contain a required property of 'label'"]) }

      context 'no fields in a namespace' do

        let(:schema) { [{ 'label' => 'Social settings' }] }
        it { is_expected.to eq(["The property '#/0' did not contain a required property of 'fields'"]) }

      end

      context 'missing the name property in a field' do

        let(:schema) { [{ 'label' => 'Social', 'fields' => [{ 'label' => 'Facebook ID' }] }] }
        it { is_expected.to eq(["The property '#/0/fields/0' did not contain a required property of 'name'"]) }

      end

      context 'wrong fields types' do

        let(:schema) { [{ 'label' => 'Social', 'fields' => [{ 'name' => 'facebook_id', 'type' => 'dummy' }] }] }
        it { is_expected.to eq(["The property '#/0/fields/0/type' value \"dummy\" did not match one of the following values: string, text, integer, file, image, boolean, select"]) }

      end

    end

    describe 'valid schema' do

      let(:schema) { [{ 'label' => 'Social', 'fields' => [{ 'name' => 'facebook_id' }, { 'name' => 'google_id' }] }] }
      it { is_expected.to eq([]) }

    end

  end

end
