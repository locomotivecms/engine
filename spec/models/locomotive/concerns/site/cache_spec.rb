require 'spec_helper'

describe Locomotive::Concerns::Site::Cache do

  let(:enabled) { false }
  let(:site)    { build(:site, cache_enabled: enabled) }

  describe '#last_modified_at' do

    subject { site.last_modified_at }

    it { is_expected.to eq nil }

    context 'only updated_at is defined' do

      let(:site) { build(:site, updated_at: DateTime.parse('2015/10/16 00:00:00')) }
      it { is_expected.to eq DateTime.parse('2015/10/16 00:00:00') }

    end

    context 'template_version or content_version are defined' do

      let(:site) { build(:site, updated_at: DateTime.parse('2015/10/16 00:00:00'), template_version: DateTime.parse('2007/06/29 00:00:00'), content_version: DateTime.parse('2009/09/10 00:00:00')) }
      it { is_expected.to eq DateTime.parse('2009/09/10 00:00:00') }

    end

  end

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
