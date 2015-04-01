require 'spec_helper'

module Locomotive
  module Concerns
    module ContentEntry

      describe Counter do

        let(:content_type) { create_content_type }

        subject { content_type.reload }

        describe 'by default' do

          it { expect(subject.number_of_entries).to be_nil }

        end

        describe 'adding entries' do

          before { 2.times { create_content_entry } }

          it { expect(subject.number_of_entries).to eq(2) }

          describe 'then removing a single entry' do

            before { subject.entries.last.destroy; content_type.reload }

            it { expect(subject.number_of_entries).to eq(1) }

          end

        end

        def create_content_type
          allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true)
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
