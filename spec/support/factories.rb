FactoryGirl.define do

  ## Site ##
  factory :site, :class => Locomotive::Site do
    name 'Acme Website'
    subdomain 'acme'
    created_at Time.now

    factory 'test site' do
      name 'Locomotive test website'
      subdomain 'test'

      after_build do |site_test|
        site_test.memberships.build :account => Locomotive::Account.where(:name => 'Admin').first || Factory('admin user'), :role => 'admin'
      end

      factory 'another site' do
        name 'Locomotive test website #2'
        subdomain 'test2'
      end

    end

    factory 'existing site' do
      name 'Locomotive site with existing models'
      subdomain 'models'
      after_build do |site_with_models|
        site_with_models.content_types.build(
          :slug => 'projects',
          :name => 'Existing name',
          :description => 'Existing description',
          :order_by => 'created_at')
      end

    end

    factory 'valid site' do
      # after_build { |valid_site| valid_site.stubs(:valid?).returns(true) }
    end

  end

  # Accounts ##
  factory :account, :class => Locomotive::Account do
    name 'Bart Simpson'
    email 'bart@simpson.net'
    password 'easyone'
    password_confirmation 'easyone'
    locale 'en'

    factory 'admin user' do
      name 'Admin'
      email 'admin@locomotiveapp.org'
    end

    factory 'frenchy user' do
      name 'Jean Claude'
      email 'jean@frenchy.fr'
      locale 'fr'
    end

    factory 'brazillian user' do
      name 'Jose Carlos'
      email 'jose@carlos.com.br'
      locale 'pt-BR'
    end

    factory 'italian user' do
      name 'Paolo Rossi'
      email 'paolo@paolo-rossi.it'
      locale 'it'
    end

  end

  ## Memberships ##
  factory :membership, :class => Locomotive::Membership do
    role 'admin'
    account { Locomotive::Account.where(:name => 'Bart Simpson').first || Factory('admin user') }

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
  factory :page, :class => Locomotive::Page do
    title 'Home page'
    slug 'index'
    published true
    site { Locomotive::Site.where(:subdomain => 'acme').first || Factory(:site) }

    factory :sub_page do
      title 'Subpage'
      slug 'subpage'
      published true
      site { Locomotive::Site.where(:subdomain => 'acme').first || Factory(:site) }
      parent { Locomotive::Page.where(:slug => 'index').first || Factory(:page) }
    end

  end

  ## Snippets ##
  factory :snippet, :class => Locomotive::Snippet do
    name 'My website title'
    slug 'header'
    template %{<title>Acme</title>}
    site { Locomotive::Site.where(:subdomain => 'acme').first || Factory(:site) }
  end


  ## Assets ##
  factory :asset, :class => Locomotive::ContentAsset do
    site { Locomotive::Site.where(:subdomain => 'acme').first || Factory(:site) }
  end


  ## Theme assets ##
  factory :theme_asset, :class => Locomotive::ThemeAsset do
    site { Locomotive::Site.where(:subdomain => 'acme').first || Factory(:site) }
  end

  ## Content types ##
  factory :content_type, :class => Locomotive::ContentType do
    name 'My project'
    description 'The list of my projects'
    site { Locomotive::Site.where(:subdomain => 'acme').first || Factory(:site) }
  end

  factory :content_entry, :class => Locomotive::ContentEntry do
  end

end
