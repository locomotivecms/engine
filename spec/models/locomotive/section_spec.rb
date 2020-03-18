# encoding: utf-8

describe Locomotive::Section do

  let(:section) { build(:section) }

  it 'has a valid factory' do
    expect(section).to be_valid
  end

  describe 'validation' do

    %w{site name template definition}.each do |field|
      it "validates presence of #{field}" do
        section.send(:"#{field}=", nil)
        expect(section).to_not be_valid
        expect(section.errors[field.to_sym].first).to eq("can't be blank")
      end
    end

    describe 'definition validation' do

      it 'requires the name property' do
        section = build(:section, definition: { settings: [] })
        expect(section).to_not be_valid
        expect(section.errors[:definition]).to eq(["The property '#/' did not contain a required property of 'name'"])
      end

      it 'requires the settings property' do
        section = build(:section, definition: { name: 'header' })
        expect(section).to_not be_valid
        expect(section.errors[:definition]).to eq(["The property '#/' did not contain a required property of 'settings'"])
      end

      describe 'settings validation' do

        it 'requires the id property' do
          section = build(:section, definition: { settings: [{ label: 'Hello world', type: 'text' }] })
          expect(section).to_not be_valid
          expect(section.errors[:definition]).to eq(["The property '#/settings/0' did not contain a required property of 'id'"])
        end

        it 'requires the type property' do
          section = build(:section, definition: { settings: [{ id: 'title', label: 'Hello world' }] })
          expect(section).to_not be_valid
          expect(section.errors[:definition]).to eq(["The property '#/settings/0' did not contain a required property of 'type'"])
        end

        it 'requires the type property to be included in the list of available ones' do
          section = build(:section, definition: { settings: [{ id: 'title', label: 'Hello world', type: 'color' }] })
          expect(section).to_not be_valid
          expect(section.errors[:definition]).to eq(["The property '#/settings/0/type' value \"color\" did not match one of the following values: text, image_picker, checkbox, select, url, radio, content_type, content_entry, hint, integer"])
        end

      end

    end

  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)     { section }
    let(:attribute) { :template_version }

  end

end
