require 'spec_helper'

describe Locomotive::API::Entities::ContentAssetEntity do

  subject { described_class }

  %i(content_type width height vignette_url alternative_vignette_url).each do |exposure|
    it { is_expected.to represent(exposure) }
  end
  describe 'overrides' do
    let!(:asset) { create(:asset) }

    subject { described_class.new(asset) }
    let(:exposure) { subject.serializable_hash }
    before { subject.object.source_filename = 'very-long-file-name-that-is-used' }

    describe 'full_file_name' do
      it 'returns the full file name' do
        expect(exposure[:full_filename]).to eq 'very-long-file-name-that-is-used'
      end
    end

    describe 'short_name' do
      it 'returns filename truncated to 15 chars' do
        expect(exposure[:short_name]).to eq 'very-long-fi...'
      end
    end

    describe 'extname' do
      it 'returns the file extension truncated to 3 chars' do
        subject.object.source_filename = 'foo.barbaz'
        expect(exposure[:extname]).to eq '...'
      end

      it 'returns the file extension if 3 chars' do
        subject.object.source_filename = 'foo.baz'
        expect(exposure[:extname]).to eq 'baz'
      end
    end

    describe 'content_type_text' do
      context 'content_type is other' do
        context 'file extension blank' do
          it 'returns a question mark' do
            expect(exposure[:content_type_text]).to eq '?'
          end
        end

        context 'file extension not blank' do
          before { subject.object.source_filename = 'foo.bar' }
          it 'returns the file extension' do
            expect(exposure[:content_type_text]).to eq 'bar'
          end
        end
      end

      context 'content_type is a string' do
        it 'returns the content_type' do
          subject.object.content_type = 'string'
          expect(exposure[:content_type_text]).to eq 'string'
        end
      end
    end

    describe 'with_thumbnail' do
      context 'content_type is other' do
        it 'returns false' do
          expect(exposure[:with_thumbnail]).to be_falsey
        end
      end

      context 'content_type is image or pdf' do
        before do
          subject.object.width = '50'
          subject.object.height = '50'
        end

        specify 'image returns true' do
          subject.object.content_type = 'image'
          expect(exposure[:with_thumbnail]).to be_truthy
        end

        specify 'pdf returns true' do
          subject.object.content_type = 'pdf'
          expect(exposure[:with_thumbnail]).to be_truthy
        end
      end
    end

    describe 'raw_size' do
      it 'returns the size' do
        expect(exposure[:raw_size]).to eq asset.size
      end
    end

    describe 'url' do
      it 'returns the source URL' do
        expect(exposure[:url]).to eq asset.source.url
      end
    end

  end
  
end
