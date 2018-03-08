# encoding: utf-8

describe Locomotive::ContentAssetService do

  let(:site)    { create('test site') }
  let(:service) { described_class.new(site) }

  describe '#list' do

    let!(:asset) { create(:asset, site: site) }

    subject { service.list }

    it { expect(subject.size) == 1 }

  end

  describe '#bulk_create' do

    let(:assets) { [] }

    subject { service.bulk_create(assets) }

    it { expect(subject.size).to eq 0 }

    context 'with a non empty list' do

      let(:assets) { [
        { source: FixturedAsset.open('5k.png') },
        { source: FixturedAsset.open('5k_2.png') }
      ] }

      it { expect(subject.size).to eq 2 }

      it 'creates content assets' do
        expect { subject }.to change(Locomotive::ContentAsset, :count).by(2)
      end

    end

    context 'with a wrong asset' do

      let(:assets) { [
        { source: FixturedAsset.open('5k.png') },
        { source: nil }
      ] }

      it 'creates content assets' do
        expect { subject }.to change(Locomotive::ContentAsset, :count).by(1)
      end

    end

  end

end
