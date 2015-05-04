# coding: utf-8

require 'spec_helper'

describe Locomotive::ContentAsset do

  describe 'attaching a file' do

    let(:asset) { FactoryGirl.build(:asset, source: FixturedAsset.open('5k.png')) }

    before { allow_any_instance_of(Locomotive::ContentAsset).to receive(:site_id).and_return('test') }

    it 'should process picture' do
      expect(asset.source.file.content_type).to_not eq(nil)
      expect(asset.image?).to eq(true)
    end

    it 'should get width and height from the image' do
      expect(asset.width).to eq(32)
      expect(asset.height).to eq(32)
    end

  end

  describe 'vignette' do

    let(:asset) { FactoryGirl.build(:asset, source: FixturedAsset.open('5k.png')) }

    it 'does not resize image smaller than 50x50' do
      expect(asset.vignette_url).to match(/^\/spec\/.*\/5k.png/)
    end

    it 'has any possible resized versions' do
      allow(asset).to receive(:with).and_return(90)
      allow(asset).to receive(:height).and_return(90)
      expect(asset.vignette_url).to match(/^\/images\/dynamic\/.*\/5k.png/)
    end

  end

  describe 'attaching a pdf' do

    subject { FactoryGirl.build(:asset, source: FixturedAsset.open('specs.pdf')) }

    it { expect(subject.pdf?).to eq(true) }
    it { expect(subject.vignette_url).to match(/^\/images\/dynamic\/.*\/specs.png/) }

  end

  describe '#checksum' do

    let(:asset) { FactoryGirl.create(:asset, source: FixturedAsset.open('5k.png')) }

    it { expect(asset.checksum).not_to eq nil }

  end

end
