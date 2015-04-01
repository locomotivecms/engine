require 'spec_helper'
module Locomotive
  describe SnippetEntity do
    subject { SnippetEntity }

    it { is_expected.to represent(:name) }
    it { is_expected.to represent(:slug) }
    it { is_expected.to represent(:template) }


    context 'overrides' do
      let!(:snippet) { create(:snippet) }
      subject { Locomotive::SnippetEntity.new(snippet) }
      let(:exposure) { subject.serializable_hash }

      describe 'updated_at' do
        it 'runs updated_at through #short_date' do
          expect(subject).to receive(:short_date) do
            exposure[:updated_at]
          end
        end
      end

    end

  end
end
