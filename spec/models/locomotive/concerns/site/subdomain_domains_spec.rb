require 'spec_helper'

describe Locomotive::Concerns::Site::SubdomainDomains do

  describe '#subdomain=' do
    let(:site) { Locomotive::Site.new }

    it 'downcases the subdomain' do
      site.subdomain = 'MiXeDCaSe'

      expect(site.subdomain).to eq('mixedcase')
    end
  end

  describe '#domains=' do
    let(:site) { Locomotive::Site.new }

    it 'downcases the domains' do
      site.domains = ['FIRST.com', 'second.com', 'THIRD.com']

      expect(site.domains).to eq(['first.com', 'second.com', 'third.com'])
    end
  end

end
