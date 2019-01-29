# encoding: utf-8

describe Locomotive::Concerns::Page::Sections do

  let(:sections_content)          { nil }
  let(:sections_dropzone_content) { nil }
  let(:page) { build(:page, sections_content: sections_content, sections_dropzone_content: sections_dropzone_content) }

  describe 'validation' do

    let(:sections_content) { { 'the_header_of_wonder': { 'settings': { 'title': 'wonderfull title' } } } }

    it { expect(page).to be_valid }

    describe "can't be an array" do

      let(:sections_content) { [] }

      it { expect { page }.to raise_error }

    end

    describe "must not contain additional properties" do

      let(:sections_content) { { 'id': { 'not': 'good' } } }

      it 'raises an error' do
        expect(page).not_to be_valid
        expect(page.errors[:sections_content]).to eq(["The property '#/id' contains additional properties [\"not\"] outside of the schema when none are allowed"])
      end

    end

  end

  describe '#all_sections_content' do

    subject { page.all_sections_content }

    it { is_expected.to eq([]) }

    context 'with content' do

      let(:sections_dropzone_content) { [
        { 'anchor' => 'banner-23e', 'type': 'banner', 'settings': { 'image': 'banner.png' } },
        { 'type': 'banner', 'settings': { 'image': 'banner.png' } },
      ] }
      let(:sections_content) { { 'the_header_of_wonder' => { 'type': 'text', 'settings': { 'title': 'wonderfull title' } } } }

      it 'groups all kind of sections (global and within a dropzone) by their id' do
        expect(subject.map { |s| s['anchor'] }).to eq(['banner-23e-section', 'dropzone-1-section', 'page-the_header_of_wonder-section'])
      end

    end

  end

end
