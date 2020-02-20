require 'spec_helper'

describe Locomotive::ContentEntriesHelper do

  around do |ex|
    without_partial_double_verification { ex.run }
  end

  let(:site)          { build(:site) }
  let(:content_type)  { build_content_type }

  describe '#each_content_entry_group' do

    before { allow(helper).to receive(:current_site).and_return(site) }
    subject do
      [].tap do |value|
        helper.each_content_entry_group(content_type) do |hash|
          value << [hash[:name], hash[:url]]
        end
      end
    end

    context 'grouped by an checkbox field' do

      before { content_type.group_by_field_id = 'visible' }

      it 'displays the 2 groups (true|false)' do
        is_expected.to eq([
          ['Visible? (Yes)', "/locomotive/acme/content_types/#{content_type.slug}/entries?group=Visible%3F+%28Yes%29&where=%7B%22visible%22%3A+true%7D"],
          ['Visible? (No)', "/locomotive/acme/content_types/#{content_type.slug}/entries?group=Visible%3F+%28No%29&where=%7B%22visible%22%3A+false%7D"]
        ])
      end

    end
  end

  def build_content_type
    build(:content_type).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string'
      content_type.entries_custom_fields.build label: 'Visible?', type: 'boolean', name: 'visible'
    end
  end

end
