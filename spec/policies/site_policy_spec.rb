require 'spec_helper'

module Locomotive
  describe SitePolicy do
    let(:site)     { FactoryGirl.create(:site, domains: %w{www.acme.com}) }
    let(:account)  { FactoryGirl.create(:account) }

    subject { SitePolicy }

    context '#create?' do
      context 'without site' do

        context 'admin' do
          let!(:membership) do
            FactoryGirl.create(:membership, account: account, site: site, role: 'admin')
          end

          permissions :create? do
            it('yes') { expect(subject).to permit(account, site) }
          end
        end

        context 'anybody' do
          permissions :create? do
            it('no') { expect(subject).to_not permit(account, site) }
          end
        end
      end

      context 'with site' do
        context 'designer' do
          let!(:membership) do
            FactoryGirl.create(:membership, account: account, site: site, role: 'designer')
          end

          permissions :create? do
            it('no') { expect(subject).to_not permit(account, site) }
          end
        end

        context 'author' do
          let!(:membership) do
            FactoryGirl.create(:membership, account: account, site: site, role: 'author')
          end

          permissions :create? do
            it('no') { expect(subject).to_not permit(account, site) }
          end
        end
      end
    end

  end
end
