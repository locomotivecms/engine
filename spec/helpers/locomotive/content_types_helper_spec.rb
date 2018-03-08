require 'spec_helper'

describe Locomotive::ContentTypesHelper do

  around do |ex|
    without_partial_double_verification { ex.run }
  end

  before do
    ::Mongoid::Fields::I18n.locale = 'de'
    ::Mongoid::Fields::I18n.fallbacks_for('en', ['en', 'de'])
  end

  after(:all) do
    ::Mongoid::Fields::I18n.locale = 'en'
    ::Mongoid::Fields::I18n.clear_fallbacks
  end

  before { allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true) }

  let(:site)          { create(:site, locales: ['de', 'en']) }
  let(:localized)     { false }
  let(:content_type)  { create_content_type(site, localized) }

  describe '#entry_label' do

    before { allow(helper).to receive(:current_site).and_return(site) }

    let!(:entry) { content_type.entries.create(title: 'Hallo Welt') }

    subject { helper.entry_label(content_type, entry) }

    context 'not localized' do

      it { expect(subject).to match /<a href="\/locomotive\/acme\/content_types\/[^\/]+\/entries\/[^\/]+\/edit">Hallo Welt<\/a>/ }

    end

    context 'localized' do

      let(:localized) { true }

      it { expect(subject).to match /<a href="\/locomotive\/acme\/content_types\/[^\/]+\/entries\/[^\/]+\/edit">Hallo Welt<\/a>/ }

      context 'viewed in another locale' do

        it 'returns a default label' do
          ::Mongoid::Fields::I18n.with_locale('en') do
            expect(entry.reload.title_translations['en']).to eq nil
            expect(subject).to match /<a href="\/locomotive\/acme\/content_types\/[^\/]+\/entries\/[^\/]+\/edit">Hallo Welt<\/a>/
          end
        end

      end

    end

  end

  def create_content_type(site, localized = false)
    build(:content_type).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string', localized: localized
      content_type.entries_custom_fields.build label: 'Description', type: 'text', localized: localized
      content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible', localized: localized
      content_type.entries_custom_fields.build label: 'File', type: 'file', localized: localized
      content_type.save
    end.reload
  end

end
