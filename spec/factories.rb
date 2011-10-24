FactoryGirl.define do

  ## Site ##
  factory :site do
    name 'Acme Website'
    subdomain 'acme'
    created_at Time.now

    factory "test site" do
      name 'Locomotive test website'
      subdomain 'test'

      after_build do |site_test|
        site_test.memberships.build :account => Account.where(:name => "Admin").first || Factory("admin user"), :role => 'admin'
      end

      factory "another site" do
        name "Locomotive test website #2"
        subdomain "test2"
      end

    end

    factory "existing site" do
      name "Locomotive site with existing models"
      subdomain "models"
      after_build do |site_with_models|
        site_with_models.content_types.build(
          :slug => 'projects',
          :name => 'Existing name',
          :description => 'Existing description',
          :order_by => 'created_at')
      end

    end

    factory "valid site" do
      # after_build { |valid_site| valid_site.stubs(:valid?).returns(true) }
    end

  end

  # Accounts ##
  factory :account do
    name 'Bart Simpson'
    email 'bart@simpson.net'
    password 'easyone'
    password_confirmation 'easyone'
    locale 'en'

    factory "admin user" do
      name "Admin"
      email "admin@locomotiveapp.org"
    end

    factory "frenchy user" do
      name "Jean Claude"
      email "jean@frenchy.fr"
      locale 'fr'
    end

    factory "brazillian user" do
      name "Jose Carlos"
      email "jose@carlos.com.br"
      locale 'pt-BR'
    end

    factory "italian user" do
      name "Paolo Rossi"
      email "paolo@paolo-rossi.it"
      locale 'it'
    end

  end

  ## Memberships ##
  factory :membership do
    role 'admin'
    account { Account.where(:name => "Bart Simpson").first || Factory('admin user') }

    factory :admin do
      role 'admin'
      account { Factory('admin user', :locale => 'en') }
    end

    factory :designer do
      role 'designer'
      account { Factory('frenchy user', :locale => 'en') }
    end

    factory :author do
      role 'author'
      account { Factory('brazillian user', :locale => 'en') }
    end

  end

  ## Pages ##
  factory :page do
    title 'Home page'
    slug 'index'
    published true
    site { Site.where(:subdomain => "acme").first || Factory(:site) }

    factory :sub_page do
      title 'Subpage'
      slug 'subpage'
      published true
      site { Site.where(:subdomain => "acme").first || Factory(:site) }
      parent { Page.where(:slug => "index").first || Factory(:page) }
    end

  end

  ## Snippets ##
  factory :snippet do
    name 'My website title'
    slug 'header'
    template %{<title>Acme</title>}
    site { Site.where(:subdomain => "acme").first || Factory(:site) }
  end


  ## Assets ##
  factory :asset do
    site { Site.where(:subdomain => "acme").first || Factory(:site) }
  end


  ## Theme assets ##
  factory :theme_asset do
    site { Site.where(:subdomain => "acme").first || Factory(:site) }
  end

  ## Content types ##
  factory :content_type do
    name 'My project'
    site { Site.where(:subdomain => "acme").first || Factory(:site) }
  end

  factory :content_instance do
  end

end
