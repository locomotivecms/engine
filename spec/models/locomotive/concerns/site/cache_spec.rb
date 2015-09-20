require 'spec_helper'

describe Locomotive::Concerns::Site::Cache do

  let(:enabled) { false }
  let(:site)    { build(:site, cache_enabled: enabled) }

  describe '#cache_enabled?' do

    subject { site.cache_enabled? }

    it { expect(subject).to eq false }

    context 'cache enabled' do

      let(:enabled) { true }
      it { expect(subject).to eq true }

    end

  end

  describe '#save' do

    let(:date) { Time.zone.local(2015, 4, 1, 12, 0, 0) }

    before { site.save }

    it 'bumps content_version' do
      site.name = 'New name'
      Timecop.freeze(date) do
        expect { site.save! }.to change { site.content_version }.to date
      end
    end

  end

end
