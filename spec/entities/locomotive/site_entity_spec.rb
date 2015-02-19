require 'spec_helper'
module Locomotive
  describe SiteEntity do
    subject { SiteEntity }


    %i(name locales handle domains memberships seo_title meta_keywords
      meta_description robots_txt).each do |exposure|
        it { is_expected.to represent(exposure) }
      end

    context 'overrides' do
      let!(:admin) { create(:admin) }
      let!(:site) { admin.site }

      subject { Locomotive::SiteEntity.new(site) }
      let(:exposure) { subject.serializable_hash }

      describe 'timezones' do

        it 'returns the timezone name' do
          expect(exposure[:timezone]).to eq 'UTC'
        end
      end
    end

  end
end
