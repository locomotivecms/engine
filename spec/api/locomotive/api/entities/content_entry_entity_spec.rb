require 'spec_helper'

describe Locomotive::API::Entities::ContentEntryEntity do

  subject { described_class }

  attributes =
    %i(
      _slug
      _label
      _position
      _visible
      seo_title
      meta_keywords
      meta_description
    )

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

  context 'overrides' do

    let(:content_type)  { create('article content type', :with_select_field_and_options) }
    let(:content_entry) { content_type.entries.create({
      title:          'Hello world',
      body:           'Lorem ipsum',
      picture:        FixturedAsset.open('5k.png'),
      featured:       true,
      published_on:   DateTime.parse('2009/09/10 09:00:00'),
      author_email:   'john@doe.net',
      grade:          4.2,
      duration:       420,
      tags:           ['foo', 'bar'],
      price:          42.0,
      metadata:       { var1: 'Hello', var2: 'world' },
      category_id:    content_type.entries_custom_fields.where(name: 'category').first.select_options.first._id,
      archived_at:    Date.parse('2009/09/12')
    }) }
    let(:entity) { described_class.new(content_entry) }

    subject { entity.serializable_hash }

    it 'returns the slug of the content type' do
      expect(subject[:content_type_slug]).to match /^slug_of_content_type_/
    end

    describe 'dynamic fields' do

      it 'returns the string fields' do
        expect(subject[:title]).to eq 'Hello world'
      end

      it 'returns the text fields' do
        expect(subject[:body]).to eq 'Lorem ipsum'
      end

      it 'returns the file fields' do
        expect(subject[:picture]).to match /\/5k.png$/
      end

      it 'returns the boolean fields' do
        expect(subject[:featured]).to eq true
      end

      it 'returns the date time fields' do
        expect(subject[:published_on]).to eq '2009-09-10T09:00:00+00:00'
      end

      it 'returns the date fields' do
        expect(subject[:archived_at]).to eq '2009-09-12'
      end

      it 'returns the email fields' do
        expect(subject[:author_email]).to eq 'john@doe.net'
      end

      it 'returns the float fields' do
        expect(subject[:grade]).to eq 4.2
      end

      it 'returns the integer fields' do
        expect(subject[:duration]).to eq 420
      end

      it 'returns the tags fields' do
        expect(subject[:tags]).to eq(['foo', 'bar'])
      end

      it 'returns the money fields' do
        expect(subject[:price]).to eq '42'
      end

      it 'returns the select fields' do
        expect(subject[:category]).to eq 'Development'
      end

      it 'returns the json fields' do
        expect(subject[:metadata]).to eq '{"var1":"Hello","var2":"world"}'
      end

    end

    describe 'localized dynamic fields' do

      let(:content_type)  { create('localized article content type', :with_select_field_and_options) }
      let(:content_entry) {
        ::Mongoid::Fields::I18n.with_locale(:en) do
          content_type.entries.create(title: 'Hello world')
        end
      }

      before do
        # Hack because other specs change the fallbacks.
        fallbacks = ::Mongoid::Fields::I18n.fallbacks
        if fallbacks && fallbacks[:fr].nil?
          ::Mongoid::Fields::I18n.fallbacks_for(:fr, [])
        end

        ::Mongoid::Fields::I18n.with_locale(:fr) do
          content_entry.title = 'Bonjour monde'
          content_entry.save
        end
      end

      it 'returns the string fields for the default locale' do
        expect(subject[:title]).to eq 'Hello world'
      end

      it 'returns the string fields for another locale too' do
        ::Mongoid::Fields::I18n.with_locale(:fr) do
          expect(subject[:title]).to eq 'Bonjour monde'
        end
      end

    end

  end

end
