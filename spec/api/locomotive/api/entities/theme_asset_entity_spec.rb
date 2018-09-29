require 'spec_helper'

describe Locomotive::API::Entities::ThemeAssetEntity do

  before { Time.zone = ActiveSupport::TimeZone['Chicago'] }

  subject { described_class }

  it { is_expected.to represent(:content_type) }
  it { is_expected.to represent(:folder) }
  it { is_expected.to represent(:checksum) }

  context 'overrides' do

    let(:theme_asset) { create(:theme_asset, source: rack_theme_image('rails.png')) }

    subject { described_class.new(theme_asset) }

    let(:exposure) { subject.serializable_hash }

    describe 'raw_size' do
      it 'returns the raw size' do
        expect(exposure[:raw_size]).to eq(theme_asset.source.size)
      end
    end

    describe 'local_path' do
      it 'returns the local path' do
        expect(exposure[:local_path]).to eq(theme_asset.local_path)
      end
    end

    describe 'url' do
      it 'returns the source URL' do
        expect(exposure[:url]).to eq(theme_asset.source.url)
      end
    end

    describe 'size' do
      it 'runs size through #number_to_human_size' do
        expect(subject).to receive(:number_to_human_size).and_return('6.49 KB')
        exposure[:size]
      end
    end

    describe 'updated_at' do
      it 'runs updated_at through #iso_timestamp' do
        travel_to(Time.zone.local(2015, 4, 1, 12, 0, 0)) do
          expect(exposure[:updated_at]).to eq '2015-04-01T12:00:00Z'
        end
      end
    end

  end

end
