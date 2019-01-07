# coding: utf-8

require 'spec_helper'

describe Locomotive::CustomFieldService do

  let(:content_type)  { build(:content_type, :with_select_field) }
  let(:field)         { content_type.entries_custom_fields.last }
  let(:service)       { described_class.new(field) }

  describe '#update_select_options' do

    let(:content_type)  { build(:content_type, :with_select_field) }
    let(:options)       { nil }
    subject             { service.update_select_options(options) }

    it { expect(subject).to eq nil }

    describe 'create options' do

      let(:options) { [{ name: 'Marketing' }, { name: 'Development' }] }

      it { expect(subject.map(&:name)).to eq ['Marketing', 'Development'] }

    end

    context 'existing options' do

      let(:content_type)  { build(:content_type, :with_select_field_and_options) }
      let(:first_option)  { field.select_options.first }

      describe 'update and create' do

        let(:options) { [{ name: 'Marketing' }, { name: 'Development in Ror', _id: first_option._id }] }

        it { expect(subject.map(&:name)).to eq ['Development in Ror', 'Design', 'Marketing'] }

      end

      describe 'destroy' do

        let(:options) { [{ _destroy: '1', _id: first_option._id }] }

        it { expect(subject.map(&:name)).to eq ['Design'] }

      end

    end

    context 'a content entry exists' do

      let(:content_type)      { create(:content_type, :with_select_field_and_options) }
      let(:first_option)      { field.select_options.first }
      let(:last_option)       { field.select_options.last }
      let!(:content_entry)    { content_type.entries.create!(title: 'Hello world', category_id: first_option._id) }
      let(:content_entry_id)  { content_entry._id }

      describe 'add a new option and assign it to the content entry' do

        let(:options) { [{ name: 'Marketing' }, { name: 'Development in RoR', _id: first_option._id }, { name: 'Design', _id: last_option._id }] }

        it 'sucessfully saves the modified content entry' do
          expect(subject.map(&:name)).to eq(['Development in RoR', 'Design', 'Marketing'])
          new_category_id   = subject.last._id
          content_entry     = content_type.entries.find(content_entry_id)
          content_entry.category_id = new_category_id
          expect(content_entry.save).to eq true
          expect(content_entry.category).to eq 'Marketing'
        end

      end

    end

  end

end
