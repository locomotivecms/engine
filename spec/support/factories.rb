# encoding: utf-8

FactoryGirl.define do

  ## Site ##
  factory :site, class: Locomotive::Site do
    name 'Acme Website'
    subdomain 'acme'
    created_at Time.now

    factory 'test site' do
      name 'Locomotive test website'
      subdomain 'test'

      after(:build) do |site_test|
        site_test.memberships.build account: Locomotive::Account.where(name: 'Admin').first || create('admin user'), role: 'admin'
      end

      factory 'another site' do
        name 'Locomotive test website #2'
        subdomain 'test2'
      end

    end

    factory 'existing site' do
      name 'Locomotive site with existing models'
      subdomain 'models'
      after(:build) do |site_with_models|
        site_with_models.content_types.build(
          slug: 'projects',
          name: 'Existing name',
          description: 'Existing description',
          order_by: 'created_at')
      end

    end

    factory 'valid site' do
      # after(:build) { |valid_site| valid_site.stubs(:valid?).returns(true) }
    end

  end

  # Accounts ##
  factory :account, class: Locomotive::Account do
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

    factory 'polish user' do
      name 'Paweł Wilk'
      email 'pawel@randomseed.pl'
      locale 'pl'
    end

    factory 'japanese user' do
      name 'OSA Shunsuke'
      email 'xxxcaqui@gmail.com'
      locale 'ja'
    end

    factory 'bulgarian user' do
      name 'Lyuben Petrov'
      email 'lyuben.y.petrov@gmail.com'
      locale 'bg'
    end
  end

  ## Memberships ##
  factory :membership, class: Locomotive::Membership do
    role 'admin'
    account { Locomotive::Account.where(name: 'Bart Simpson').first || FactoryGirl.create('admin user') }

    factory :admin do
      role 'admin'
      account { FactoryGirl.create('admin user', locale: 'en') }
    end

    factory :designer do
      role 'designer'
      account { FactoryGirl.create('frenchy user', locale: 'en') }
    end

    factory :author do
      role 'author'
      account { FactoryGirl.create('brazillian user', locale: 'en') }
    end

  end

  ## Pages ##
  factory :page, class: Locomotive::Page do
    title 'Home page'
    slug 'index'
    published true
    site { Locomotive::Site.where(subdomain: 'acme').first || FactoryGirl.create(:site) }

    factory :sub_page do
      title 'Subpage'
      slug 'subpage'
      published true
      site { Locomotive::Site.where(subdomain: 'acme').first || FactoryGirl.create(:site) }
      parent { Locomotive::Page.where(slug: 'index').first || FactoryGirl.create(:page) }
    end

  end

  ## Snippets ##
  factory :snippet, class: Locomotive::Snippet do
    name 'My website title'
    slug 'header'
    template %{<title>Acme</title>}
    site { Locomotive::Site.where(subdomain: 'acme').first || FactoryGirl.create(:site) }
  end


  ## Assets ##
  factory :asset, class: Locomotive::ContentAsset do
    site { Locomotive::Site.where(subdomain: 'acme').first || FactoryGirl.create(:site) }
  end


  ## Theme assets ##
  factory :theme_asset, class: Locomotive::ThemeAsset do
    site { Locomotive::Site.where(subdomain: 'acme').first || FactoryGirl.create(:site) }
  end

  ## Content types ##
  factory :content_type, class: Locomotive::ContentType do
    name 'My project'
    description 'The list of my projects'
    site { Locomotive::Site.where(subdomain: 'acme').first || FactoryGirl.create(:site) }
  end

  factory :content_entry, class: Locomotive::ContentEntry do
  end

  factory :translation, class: Locomotive::Translation do
  end

end
