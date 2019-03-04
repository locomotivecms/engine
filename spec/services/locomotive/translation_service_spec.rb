# encoding: utf-8

describe Locomotive::TranslationService do

  let(:site)    { create('test site') }
  let(:account) { create(:account) }
  let(:service) { described_class.new(site, account) }

  describe '#bulk_destroy' do

    let!(:translation_1) { create(:translation, site: site) }
    let!(:translation_2) { create(:translation, site: site) }
    let!(:translation_3) { create(:translation, site: site) }
    let!(:translation_4) { create(:translation, site: create(:site)) }

    subject { service.bulk_destroy([translation_1._id, translation_3._id, translation_4._id]) }

    it { is_expected.to eq [translation_1._id, translation_3._id] }

    it { expect { subject }.to change(site.translations, :count).by(-2) }

  end

end
