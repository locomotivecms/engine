# encoding: utf-8

describe Locomotive::Concerns::Site::Sections do

  let(:sections_content) { nil }
  let(:site) { build(:site, sections_content: sections_content) }

  it { expect(build(:site).sections_content).to eq({}) }

  describe 'validation' do

    let(:sections_content) { { "the_header_of_wonder": { "settings": { "title": "wonderfull title" } } } }

    it { expect(site).to be_valid }

    describe "can't be an array" do

      let(:sections_content) { [] }

      it { expect(site.sections_content).to eq nil }

      it { expect(site).not_to be_valid }
    end

    describe "must not contain additional properties" do

      let(:sections_content) { { "id": { "not": "good" } } }

      it 'marks it as invalid' do
        expect(site).not_to be_valid
        expect(site.errors[:sections_content]).to eq(["The property '#/id' contains additional properties [\"not\"] outside of the schema when none are allowed"])
      end

    end

  end

end
