require 'spec_helper'

describe Locomotive::Extensions::Site::SubdomainDomains do

  describe '#subdomain=' do
    let(:site) { Locomotive::Site.new }

    it 'downcases the subdomain' do
      site.subdomain = 'MiXeDCaSe'

      site.subdomain.should == 'mixedcase'
    end
  end

  describe '#domains=' do
    let(:site) { Locomotive::Site.new }

    it 'downcases the domains' do
      site.domains = ['FIRST.com', 'second.com', 'THIRD.com']

      site.domains.should == ['first.com', 'second.com', 'third.com']
    end
  end

end
