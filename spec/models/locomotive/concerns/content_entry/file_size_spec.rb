require 'spec_helper'

describe Locomotive::Concerns::ContentEntry::FileSize do

  let(:content_type)  { create_content_type }
  let(:content_entry) { build_content_entry }

  subject { content_entry._file_size }

  context 'entry not persisted' do

    it { expect(subject).to eq 0 }

  end

  context 'entry persisted' do

    before { content_entry.save! }

    it { expect(subject).to eq 1309 }

  end

  def create_content_type
    allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true)
    FactoryGirl.build(:content_type).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string'
      content_type.entries_custom_fields.build label: 'File 1', type: 'file'
      content_type.entries_custom_fields.build label: 'File 2', type: 'file'
      content_type.valid?
      content_type.send(:set_label_field)
      content_type.save!
    end
  end

  def build_content_entry
    content_type.entries.build(title: 'LocomotiveCMS', file_1: FixturedAsset.open('5k.png'), file_2: FixturedAsset.open('main.css'))
  end

end
