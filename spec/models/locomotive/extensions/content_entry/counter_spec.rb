require 'spec_helper'

module Locomotive
  module Extensions
    module ContentEntry

      describe Counter do

        let(:content_type) { create_content_type }

        subject { content_type.reload }

        describe 'by default' do

          its(:number_of_entries) { should be_nil }

        end

        describe 'adding entries' do

          before { 2.times { create_content_entry } }

          its(:number_of_entries) { should eq 2 }

          describe 'then removing a single entry' do

            before { subject.entries.last.destroy; content_type.reload }

            its(:number_of_entries) { should eq 1 }

          end

        end

        def create_content_type
          Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
          FactoryGirl.build(:content_type).tap do |content_type|
            content_type.entries_custom_fields.build label: 'Title', type: 'string'
            content_type.valid?
            content_type.send(:set_label_field)
            content_type.save!
          end
        end

        def create_content_entry
          content_type.entries.create!(title: 'LocomotiveCMS')
        end

      end

    end
  end
end
