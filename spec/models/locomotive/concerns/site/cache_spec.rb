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

end
