require 'spec_helper'

module Locomotive
  module Concerns
    module ContentEntry
      describe Csv do
        before(:each) do
          allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true)
          @content_type = FactoryGirl.build(:content_type)
          @content_type.entries_custom_fields.build label: 'Title', type: 'string'
          @content_type.entries_custom_fields.build label: 'Description', type: 'text'
          @content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible'
          @content_type.valid?
          @content_type.send(:set_label_field)
          @content_type.save!
        end

        it 'exports nil fields as empty strings' do
          @entry = @content_type.entries.create!({
            title: 'Locomotive',
            visible: true
          })

          values = @entry.to_values
          expect(values).to eq(['Locomotive', '', true, I18n.l(@entry.created_at, format: :long)])
        end
      end
    end
  end
end
