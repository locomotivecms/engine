# encoding: utf-8

describe Locomotive::Concerns::Site::Sections do

  let(:sections_content) { nil }
  let(:site) { build(:site, sections_content: sections_content) }

  describe 'validation' do

    let(:sections_content) { { "the_header_of_wonder": { "settings": { "title": "wonderfull title" } } } }

    it { expect(site).to be_valid }

    describe "can't be an array" do

      let(:sections_content) { [] }

      it { expect { site }.to raise_error }

    end

    describe "must not contain additional properties" do

      let(:sections_content) { { "id": { "not": "good" } } }

      it 'raises an error' do
        expect(site).not_to be_valid
        expect(site.errors[:sections_content]).to eq(["The property '#/id' contains additional properties [\"not\"] outside of the schema when none are allowed"])
      end

    end

  end

end
