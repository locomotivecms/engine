require 'spec_helper'

describe Locomotive::ContentTypesHelper do

  before do
    ::Mongoid::Fields::I18n.locale = 'de'
    ::Mongoid::Fields::I18n.fallbacks_for('en', ['en', 'de'])
  end

  after(:all) do
    ::Mongoid::Fields::I18n.locale = 'en'
    ::Mongoid::Fields::I18n.clear_fallbacks
  end

  before { Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true) }

  let(:site) { FactoryGirl.create(:site, locales: ['de', 'en']) }
  let(:localized) { false }
  let(:content_type) { create_content_type(site, localized) }

  describe '#entry_label' do

    let!(:entry) { content_type.entries.create(title: 'Hallo Welt') }

    subject { entry_label(content_type, entry) }

    context 'not localized' do

      it { subject.should == 'Hallo Welt' }

    end

    context 'localized' do

      let(:localized) { true }

      it { subject.should == 'Hallo Welt' }

      context 'viewed in another locale' do

        it 'returns a default label' do
          ::Mongoid::Fields::I18n.with_locale('en') do
            entry.reload.title_translations['en'].should == nil
            subject.should == 'Hallo Welt'
          end
        end

      end

    end

  end

  def create_content_type(site, localized = false)
    FactoryGirl.build(:content_type).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string', localized: localized
      content_type.entries_custom_fields.build label: 'Description', type: 'text', localized: localized
      content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible', localized: localized
      content_type.entries_custom_fields.build label: 'File', type: 'file', localized: localized
      content_type.save
    end.reload
  end

end
