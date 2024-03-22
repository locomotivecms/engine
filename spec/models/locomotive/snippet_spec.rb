# encoding: utf-8

describe Locomotive::Snippet do

  let(:snippet) { build(:snippet) }

  it 'has a valid factory' do
    expect(snippet).to be_valid
  end

  # Validations ##

  %w{site name template}.each do |field|
    it "validates presence of #{field}" do
      snippet.send(:"#{field}=", nil)
      expect(snippet).to_not be_valid
      expect(snippet.errors[field.to_sym].first).to eq("can't be blank")
    end
  end

  it_should_behave_like 'model scoped by a site' do
    let(:model)     { snippet }
    let(:attribute) { :template_version }
  end

  describe '.by_id_or_slug' do
    let(:site) { create(:site) }

    before do
      create(:snippet, slug: 'header', site: site)
      create(:snippet, slug: 'footer', site: site)
    end
    
    subject { site.snippets.by_id_or_slug(slug).first }

    describe 'Given there is no snippet in DB matching the slug' do
      let(:slug) { 'unknown' }

      it { is_expected.to eq nil }
    end

    describe 'Given there is a snippet in DB matching the slug' do
      let(:slug) { 'header' }

      it 'returns the snippet' do
        expect(subject.slug).to eq 'header'
      end
    end
  end
end
