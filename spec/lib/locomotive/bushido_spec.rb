require 'spec_helper'

describe 'Bushido support' do

  before(:each) do
    ::Bushido::App.stubs(:subdomain_available?).returns(true)
  end

  context '#loaded' do

    it 'has method to enable bushido' do
      Locomotive.respond_to?(:enable_bushido).should be_true
    end

    it 'tells bushido is disabled' do
      Locomotive.bushido?.should be_false
    end

    it 'does not add instance methods to Site' do
      Site.should_not include_instance_method :add_bushido_domains
      Site.should_not include_instance_method :remove_bushido_domains

      Site.should_not include_class_method :create_first_one_with_bushido
    end

  end

  context '#disabled' do

    before(:each) do
      Locomotive.configure do |config|
        config.hosting = :none
      end
    end

    it 'tells bushido is disabled' do
      Locomotive.bushido?.should be_false
    end

    it 'does not add methods to Site' do
      Site.should_not include_instance_method :add_bushido_domains
      Site.should_not include_instance_method :remove_bushido_domains
    end

  end

  context '#enabled' do

    it 'tells bushido is enabled from ENV' do
      ENV['APP_TLD'] = 'bushi.do'
      Locomotive.config.hosting = :auto
      Locomotive.bushido?.should be_true
    end

    it 'adds a method to automatically create a site with Bushido settings' do
      configure_locomotive_with_bushido
      Site.should include_class_method :create_first_one_with_bushido
    end

    it 'tells bushido is enabled when forcing it' do
      configure_locomotive_with_bushido
      Locomotive.bushido?.should be_true
    end

    describe 'events' do

      before(:each) do
        configure_locomotive_with_bushido
        @site = FactoryGirl.build('test site')
        @account = @site.memberships.first.account
        Account.stubs(:first).returns(@account)
      end

      it 'responds to the app.claimed event' do
        ::Bushido::Data.call('app.claimed')
        @account.name.should == 'san_francisco'
        @account.email.should == 'san_francisco@bushi.do'
      end

    end

    context 'enhancing site' do

      before(:each) do
        configure_locomotive_with_bushido
        @site = FactoryGirl.build('valid site')
      end

      it 'calls add_bushido_domains after saving a site' do
        @site.expects(:add_bushido_domains)
        @site.save
      end

      it 'calls remove_bushido_domains after saving a site' do
        @site.expects(:remove_bushido_domains)
        @site.destroy
      end

      context 'adding domain' do

        it 'does not add new domain if no delta' do
          ::Bushido::App.expects(:add_domain).never
          @site.save
        end

        it 'adds a new domain if new one' do
          @site.domains = ['www.acme.fr']
          ::Bushido::App.expects(:add_domain).with('www.acme.fr')
          @site.save
          Locomotive.bushido_domains.should include('www.acme.fr')
        end
      end

      context 'changing subdomain' do

        it 'does not change it if not modified' do
          ::Bushido::App.expects(:set_subdomain).never
          @site.save
        end

        it 'does not change it if Locomotive is launched with multi sites' do
          @site.save
          @site.subdomain = 'rope'
          ::Bushido::App.expects(:set_subdomain).never
          @site.save
        end

        it 'changes the bushido name' do
          configure_locomotive_with_bushido do |config|
            config.multi_sites = false
          end
          @site.save
          @site.subdomain = 'rope'
          ::Bushido::App.expects(:set_subdomain).with('rope')
          @site.save
        end

      end

      context 'removing domain' do

        it 'does not remove domain if no delta' do
          ::Bushido::App.expects(:remove_domain).never
          @site.destroy
        end

        it 'removes domains if we destroy a site' do
          @site.stubs(:domains_without_subdomain).returns(['www.acme.com'])
          ::Bushido::App.expects(:remove_domain).with('www.acme.com')
          @site.destroy
          Locomotive.bushido_domains.should_not include('www.acme.com')
        end

        it 'removes domain if removed' do
          ::Bushido::App.stubs(:add_domain)
          @site.domains = ['www.acme.fr']; @site.save
          @site.domains = ['www.acme.com']
          ::Bushido::App.expects(:remove_domain).with('www.acme.fr')
          @site.save
          Locomotive.bushido_domains.should_not include('www.acme.fr')
        end

      end

    end

  end

  def configure_locomotive_with_bushido(&block)
    ::Bushido::App.stubs(:subdomain).returns('locomotive')
    ::Bushido::App.stubs(:domains).returns(['www.acme.com', 'example.com', 'www.example.com'])

    Locomotive.configure do |config|
      config.hosting = :bushido

      block.call(config) if block_given?

      Locomotive.define_subdomain_and_domains_options

      Object.send(:remove_const, 'Site') if Object.const_defined?('Site')
      load 'site.rb'
    end
  end

  after(:all) do
    Locomotive.configure_for_test(true)
  end

end
