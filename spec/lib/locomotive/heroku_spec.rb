require 'spec_helper'

describe 'Heroku support' do

  before(:each) do
    ::Heroku::Client.any_instance.stubs(:post).returns(true)
    ::Heroku::Client.any_instance.stubs(:delete).returns(true)
  end

  context '#loaded' do

    it 'has method to enable heroku' do
      Locomotive.respond_to?(:enable_heroku).should be_true
    end

    it 'tells heroku is disabled' do
      Locomotive.heroku?.should be_false
    end

    it 'does not add instance methods to Site' do
      Site.should_not include_instance_method :add_heroku_domains
      Site.should_not include_instance_method :remove_heroku_domains

      Site.should_not include_class_method :create_first_one_with_heroku
    end

  end

  context '#disabled' do

    before(:each) do
      Locomotive.configure do |config|
        config.hosting = :none
      end
    end

    it 'has a nil connection' do
      Locomotive.respond_to?(:heroku_connection).should be_false
    end

    it 'tells heroku is disabled' do
      Locomotive.heroku?.should be_false
    end

    it 'does not add methods to Site' do
      Site.should_not include_instance_method :add_heroku_domains
      Site.should_not include_instance_method :remove_heroku_domains
    end

  end

  context '#enabled' do

    it 'tells heroku is enabled from ENV' do
      ENV['HEROKU_SLUG'] = 'test'
      Locomotive.config.hosting = :auto
      Locomotive.heroku?.should be_true
    end

    it 'adds a method to automatically create a site with Heroku settings' do
      configure_locomotive_with_heroku
      Site.should include_class_method :create_first_one_with_heroku
    end

    it 'tells heroku is enabled when forcing it' do
      configure_locomotive_with_heroku
      Locomotive.heroku?.should be_true
    end

    it 'raises an exception if no app name is given' do
      lambda {
        configure_locomotive_with_heroku(:name => nil)
      }.should raise_error
    end

    context 'dealing with heroku connection' do

      it 'opens a heroku connection with provided credentials' do
        configure_locomotive_with_heroku
        Locomotive.heroku_connection.user.should == 'john@doe.net'
        Locomotive.heroku_connection.password.should == 'easyone'
      end

      it 'opens a heroku connection with env credentials' do
        ::Heroku::Client.any_instance.stubs(:list_domains).returns([])
        ENV['HEROKU_LOGIN'] = 'john@doe.net'; ENV['HEROKU_PASSWORD'] = 'easyone'; ENV['APP_NAME'] = 'test'
        Locomotive.configure { |config| config.hosting = :heroku; config.heroku = {} }
        Locomotive.heroku_connection.user.should == 'john@doe.net'
        Locomotive.heroku_connection.password.should == 'easyone'
      end

    end

    context 'enhancing site' do

      before(:each) do
        configure_locomotive_with_heroku
        @site = FactoryGirl.build('valid site')
      end

      it 'calls add_heroku_domains after saving a site' do
        @site.expects(:add_heroku_domains)
        @site.save
      end

      it 'calls remove_heroku_domains after saving a site' do
        @site.expects(:remove_heroku_domains)
        @site.destroy
      end

      context 'adding domain' do

        it 'does not add new domain if no delta' do
          Locomotive.heroku_connection.expects(:add_domain).never
          @site.save
        end

        it 'adds a new domain if new one' do
          @site.domains = ['www.acme.fr']
          Locomotive.heroku_connection.expects(:add_domain).with('locomotive', 'www.acme.fr')
          @site.save
          Locomotive.heroku_domains.should include('www.acme.fr')
        end
      end

      context 'removing domain' do

        it 'does not remove domain if no delta' do
          Locomotive.heroku_connection.expects(:remove_domain).never
          @site.destroy
        end

        it 'removes domains if we destroy a site' do
          @site.stubs(:domains_without_subdomain).returns(['www.acme.com'])
          Locomotive.heroku_connection.expects(:remove_domain).with('locomotive', 'www.acme.com')
          @site.destroy
          Locomotive.heroku_domains.should_not include('www.acme.com')
        end

        it 'removes domain if removed' do
          @site.domains = ['www.acme.fr']; @site.save
          @site.domains = ['www.acme.com']
          Locomotive.heroku_connection.expects(:remove_domain).with('locomotive', 'www.acme.fr')
          @site.save
          Locomotive.heroku_domains.should_not include('www.acme.fr')
        end

      end

    end

  end

  def configure_locomotive_with_heroku(options = {}, domains = nil)
    if options.has_key?(:name)
      ENV['APP_NAME'] = options.delete(:name)
    else
      ENV['APP_NAME'] = 'locomotive'
    end

    ::Heroku::Client.any_instance.stubs(:list_domains).with(ENV['APP_NAME']).returns(domains || [
      { :domain => "www.acme.com" }, { :domain => "example.com" }, { :domain => "www.example.com" }
    ])

    Locomotive.configure do |config|
      config.hosting = :heroku
      config.heroku = { :login => 'john@doe.net', :password => 'easyone' }.merge(options)

      Locomotive.define_subdomain_and_domains_options

      Object.send(:remove_const, 'Site') if Object.const_defined?('Site')
      load 'site.rb'
    end
  end

  after(:all) do
    Locomotive.configure_for_test(true)
  end

end
