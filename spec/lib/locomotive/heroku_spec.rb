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
      Site.instance_methods.include?(:add_heroku_domains).should be_false
      Site.instance_methods.include?(:remove_heroku_domains).should be_false
    end

  end

  context '#disabled' do

    before(:each) do
      Locomotive.configure do |config|
        config.heroku = false
      end
    end

    it 'has a nil connection' do
      Locomotive.heroku_connection.should be_nil
    end

    it 'tells heroku is disabled' do
      Locomotive.heroku?.should be_false
    end

    it 'does not add methods to Site' do
      Site.instance_methods.include?(:add_heroku_domains).should be_false
      Site.instance_methods.include?(:remove_heroku_domains).should be_false
    end

  end

  context '#enabled' do

    it 'tells heroku is disabled' do
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
        ENV['HEROKU_LOGIN'] = 'john@doe.net'; ENV['HEROKU_PASSWORD'] = 'easyone'
        Locomotive.configure { |config| config.heroku = true }
        Locomotive.heroku_connection.user.should == 'john@doe.net'
        Locomotive.heroku_connection.password.should == 'easyone'
      end

    end

    context 'enhancing site' do

      before(:each) do
        configure_locomotive_with_heroku
        (@site = Factory.build(:site)).stubs(:valid?).returns(true)
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
    ::Heroku::Client.any_instance.stubs(:list_domains).with('locomotive').returns(domains || [
      { :domain => "www.acme.com" }, { :domain => "example.com" }, { :domain => "www.example.com" }
    ])
    Locomotive.configure do |config|
      config.heroku = { :name => 'locomotive', :login => 'john@doe.net', :password => 'easyone' }.merge(options)
    end
  end

end
