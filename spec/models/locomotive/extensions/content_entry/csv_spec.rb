require 'spec_helper'

module Locomotive
  module Extensions
    module ContentEntry
      describe Csv do
        before(:each) do
          Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
          @content_type = FactoryGirl.build(:content_type)
          @content_type.entries_custom_fields.build label: 'Title', type: 'string'
          @content_type.entries_custom_fields.build label: 'Description', type: 'text'
          @content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible'
          @content_type.valid?
          @content_type.send(:set_label_field)
          @content_type.save!
        end

        it 'should export nil fields as empty strings' do
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
