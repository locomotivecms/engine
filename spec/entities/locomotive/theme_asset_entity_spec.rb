require 'spec_helper'

describe Locomotive::ThemeAssetEntity do

  subject { Locomotive::ThemeAssetEntity }
  it { is_expected.to represent(:content_type) }
  it { is_expected.to represent(:folder) }
  it { is_expected.to represent(:checksum) }

  context 'overrides' do
    let(:path) { Rails.root.join('../../spec/fixtures/images/rails.png').to_s }
    let(:rack_upload) { Rack::Test::UploadedFile.new(path) }
    let!(:theme_asset) { create(:theme_asset, source: rack_upload) }
    subject { Locomotive::ThemeAssetEntity.new(theme_asset) }
    let(:exposure) { subject.serializable_hash }

    describe 'raw_size' do
      it 'returns the raw size' do
        expect(exposure[:raw_size]).to eq(theme_asset.size)
      end
    end

    describe 'local_path' do
      it 'returns the local path' do
        expect(exposure[:local_path]).to eq(theme_asset.local_path(true))
      end
    end

    describe 'url' do
      it 'returns the source URL' do
        expect(exposure[:url]).to eq(theme_asset.source.url)
      end
    end

    describe 'size' do
      it 'runs size through #number_to_human_size' do
        expect(subject).to receive(:number_to_human_size)
        exposure[:size]
      end
    end

    describe 'updated_at' do
      it 'runs updated_at through #short_date' do
        expect(subject).to receive(:short_date) do
          exposure[:updated_at]
        end
      end
    end
    
  end

end
