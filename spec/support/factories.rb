# encoding: utf-8

FactoryGirl.define do

  ## Site ##
  factory :site, class: Locomotive::Site do
    name 'Acme Website'
    handle 'acme'
    # sequence(:handle) { |n| "acme#{n*rand(10_000)}" }
    created_at Time.now

    factory 'test site' do
      name 'Locomotive test website'
      handle 'test'

      after(:build) do |site_test|
        site_test.memberships.build account: Locomotive::Account.where(name: 'Admin').first || create('admin user'), role: 'admin'
      end

      factory 'another site' do
        name 'Locomotive test website #2'
        handle 'test2'
      end

    end

    factory 'existing site' do
      name 'Locomotive site with existing models'
      handle 'models'
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
    email { generate(:email) }
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

    factory 'portuguese user' do
      name 'Tiago Fernandes'
      email 'tjg.fernandes@gmail.com'
      locale 'pt'
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
    role    'admin'
    site    { build(:site) }
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
    # sequence(:slug) { |n| "index#{n*rand(10_000)}" }
    published true
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }

    trait :index do
      after(:build) do |page, evaluator|
        page.parent = page.site.pages.root.first
        page.raw_template = nil
      end
    end

    factory :sub_page do
      title 'Subpage'
      slug 'subpage'
      published true
      site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }
      parent { Locomotive::Page.where(slug: 'index').first || FactoryGirl.create(:page) }
    end

    factory :page_with_editable_element do
      slug 'with_editable_element'
      after(:build) do |page, _|
        page.editable_elements << FactoryGirl.build(:editable_element)
        page.raw_template = '<a>a</a>'
        page.save
      end
    end
  end

  ## Snippets ##
  factory :snippet, class: Locomotive::Snippet do
    name 'My website title'
    sequence(:slug) { |n| "header#{n*rand(10_000)}" }
    template %{<title>Acme</title>}
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }
  end

  ## Assets ##
  factory :asset, class: Locomotive::ContentAsset do
    source { Rack::Test::UploadedFile.new(File.join(Rails.root, '..', '..', 'spec', 'fixtures', 'images', 'rails.png'))}
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }
  end

  ## Theme assets ##
  factory :theme_asset, class: Locomotive::ThemeAsset do
    # source{Rack::Test::UploadedFile.new(File.join(Rails.root, '..', '..', 'spec', 'fixtures', 'images', 'rails.png'))}
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }
  end

  ## Content types ##
  factory :content_type, class: Locomotive::ContentType do
    sequence(:slug) { |n| "slug_of_content_type_#{n*rand(10_000)}" }

    name 'My project'
    description 'The list of my projects'
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }

    factory 'tasks content type' do
      name 'Tasks'
      description 'The list of my tasks'
    end

    factory 'message content type' do
      name 'Messages'
      slug 'messages'
      description 'Messages posted from the contact form'
      public_submission_enabled true
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Name', name: 'name', type: 'string', required: true
        content_type.entries_custom_fields.build label: 'Message', name: 'message', type: 'text'
      end
    end

    factory 'article content type' do
      name 'Articles'
      description 'The list of articles'
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Title', name: 'title', type: 'string'
        content_type.entries_custom_fields.build label: 'Body', name: 'body', type: 'text'
        content_type.entries_custom_fields.build label: 'Header picture', name: 'picture', type: 'file'
        content_type.entries_custom_fields.build label: 'Featured', name: 'featured', type: 'boolean'
        content_type.entries_custom_fields.build label: 'Published on', name: 'published_on', type: 'date_time'
        content_type.entries_custom_fields.build label: 'Author email', name: 'author_email', type: 'email'
        content_type.entries_custom_fields.build label: 'Grade', name: 'grade', type: 'float'
        content_type.entries_custom_fields.build label: 'Duration', name: 'duration', type: 'integer'
        content_type.entries_custom_fields.build label: 'Tags', name: 'tags', type: 'tags'
        content_type.entries_custom_fields.build label: 'Price', name: 'price', type: 'money'
        content_type.entries_custom_fields.build label: 'Archived at', name: 'archived_at', type: 'date'
      end
    end

    factory 'localized article content type' do
      name 'Articles'
      description 'The list of articles'
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Title', name: 'title', type: 'string', localized: true
        content_type.entries_custom_fields.build label: 'Body', name: 'body', type: 'text', localized: true
        content_type.entries_custom_fields.build label: 'Header picture', name: 'picture', type: 'file', localized: true
        content_type.entries_custom_fields.build label: 'Featured', name: 'featured', type: 'boolean', localized: true
        content_type.entries_custom_fields.build label: 'Published on', name: 'published_on', type: 'date_time', localized: true
        content_type.entries_custom_fields.build label: 'Author email', name: 'author_email', type: 'email', localized: true
        content_type.entries_custom_fields.build label: 'Grade', name: 'grade', type: 'float', localized: true
        content_type.entries_custom_fields.build label: 'Duration', name: 'duration', type: 'integer', localized: true
        content_type.entries_custom_fields.build label: 'Tags', name: 'tags', type: 'tags', localized: true
        content_type.entries_custom_fields.build label: 'Price', name: 'price', type: 'money', localized: true
        content_type.entries_custom_fields.build label: 'Archived at', name: 'archived_at', type: 'date', localized: true
      end
    end

    factory 'photo content type' do
      name 'Photos'
      description 'The list of photos'
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Title', name: 'title', type: 'string'
        content_type.entries_custom_fields.build label: 'Photo', name: 'photo', type: 'file'
      end
    end

    trait :with_field do
      after(:build) do |content_type, evaluator|
        content_type.entries_custom_fields.build label: 'Title', name: 'title', type: 'string'
      end
    end

    trait :with_text_field do
      after(:build) do |content_type, evaluator|
        content_type.entries_custom_fields.build label: 'Description', name: 'description', type: 'text'
      end
    end

    trait :with_date_time_field do
      after(:build) do |content_type, evaluator|
        content_type.entries_custom_fields.build label: 'Time', name: 'time', type: 'date_time'
      end
    end

    trait :with_select_field do
      after(:build) do |content_type, evaluator|
        content_type.entries_custom_fields.build(label: 'Category', type: 'select')
      end
    end

    trait :with_select_field_and_options do
      after(:build) do |content_type, evaluator|
        field = content_type.entries_custom_fields.build(label: 'Category', type: 'select')
        field.select_options.build name: 'Development'
        field.select_options.build name: 'Design'
      end
    end

    trait :grouped do
      after(:build) do |content_type, _|
        content_type.group_by_field_id = content_type.entries_custom_fields.last._id
      end
    end

    trait :public_submission_enabled do
      after(:build) do |content_type, _|
        content_type.public_submission_enabled = true
        content_type.public_submission_accounts = [create('admin user')._id]
      end
    end
  end

  factory :content_entry, class: Locomotive::ContentEntry do
    sequence(:_slug) { |n| "slug_of_content_entry_#{n*rand(10_000)}" }
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }
    content_type { FactoryGirl.create(:content_type, :with_field) }
  end

  factory :translation, class: Locomotive::Translation do
    sequence(:key) { |n| "key_#{n*rand(10_000)}" }
    values {{ en: 'foo', fr: 'bar', wk: 'wuuuu' }}
    site { Locomotive::Site.where(handle: 'acme').first || FactoryGirl.create(:site) }
  end

  factory :editable_element, class: Locomotive::EditableText do
    slug 'editable-element'
    block 'main'
    hint 'hint'
    content 'Lorem ipsum'
    priority 0
    disabled false
  end

  factory :custom_field, class: CustomFields::Field do
    name 'a_field'
    label 'A field'

    factory 'text field' do
      type 'text'
      text_formatting 'html'
    end

    factory 'select field' do
      type 'select'

      factory 'select field with options' do
        after(:build) do |field|
          field.select_options.build name: 'Development'
          field.select_options.build name: 'Marketing'
        end
      end
    end

    factory 'has_many field' do
      type        'has_many'
      class_name  'Locomotive::ContentType42'
      inverse_of  'somefield'
      order_by    'someotherfield'
      ui_enabled  true
    end

  end

end
