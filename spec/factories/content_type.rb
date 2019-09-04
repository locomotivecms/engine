# encoding: utf-8

FactoryBot.define do

  ## Content types ##
  factory :content_type, class: Locomotive::ContentType do

    sequence(:slug) { |n| "slug_of_content_type_#{n*rand(10_000)}" }

    name { 'My project' }
    description { 'The list of my projects' }
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }

    trait :article do
      name { 'Articles' }
      label_field_name { 'title' }
      slug { 'articles' }
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Title', type: 'string'
        content_type.entries_custom_fields.build label: 'Description', type: 'text'
        content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible'
        content_type.entries_custom_fields.build label: 'File', type: 'file'
        content_type.entries_custom_fields.build label: 'Another file', type: 'file'
        content_type.entries_custom_fields.build label: 'Published at', type: 'date'
        content_type.valid?
        content_type.send(:set_label_field)
      end
    end

    factory 'tasks content type' do
      name { 'Tasks' }
      description { 'The list of my tasks' }
    end

    factory 'message content type' do
      name { 'Messages' }
      slug { 'messages' }
      description { 'Messages posted from the contact form' }
      public_submission_enabled { true }
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Name', name: 'name', type: 'string', required: true
        content_type.entries_custom_fields.build label: 'Message', name: 'message', type: 'text'
        content_type.entries_custom_fields.build label: 'Resume', name: 'resume', type: 'file'
      end
    end

    factory 'article content type' do
      name { 'Articles' }
      description { 'The list of articles' }
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
        content_type.entries_custom_fields.build label: 'Metadata', name: 'metadata', type: 'json'
        content_type.entries_custom_fields.build label: 'Archived at', name: 'archived_at', type: 'date'
      end
    end

    factory 'localized article content type' do
      name { 'Articles' }
      description { 'The list of articles' }
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
      name { 'Photos' }
      slug { 'photos' }
      description { 'The list of photos' }
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Title', name: 'title', type: 'string'
        content_type.entries_custom_fields.build label: 'Photo', name: 'photo', type: 'file'
      end
    end

    factory 'account content type' do
      name { 'Accounts' }
      slug { 'accounts' }
      description { 'protected area' }
      after(:build) do |content_type, _|
        content_type.entries_custom_fields.build label: 'Name', name: 'name', type: 'string'
        content_type.entries_custom_fields.build label: 'Email', name: 'email', type: 'email'
        content_type.entries_custom_fields.build label: 'Password', name: 'password', type: 'password'
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
        field.select_options.build name: 'Development', position: 0
        field.select_options.build name: 'Design', position: 1
      end
    end

    trait :grouped do
      after(:build) do |content_type, _|
        content_type.group_by_field_id = content_type.entries_custom_fields.last._id
      end
    end

    trait :public_submission_enabled do
      after(:build) do |content_type, _|
        content_type.recaptcha_required = true
        content_type.public_submission_enabled = true
        content_type.public_submission_accounts = [create('admin user')._id]
      end
    end
  end

  factory :content_entry, class: Locomotive::ContentEntry do
    sequence(:_slug) { |n| "slug_of_content_entry_#{n*rand(10_000)}" }
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }
    content_type { create(:content_type, :with_field) }
  end

  factory :custom_field, class: CustomFields::Field do
    name { 'a_field' }
    label { 'A field' }

    factory 'text field' do
      type { 'text' }
      text_formatting { 'html' }
    end

    factory 'select field' do
      type { 'select' }

      factory 'select field with options' do
        after(:build) do |field|
          field.select_options.build name: 'Development'
          field.select_options.build name: 'Marketing'
        end
      end
    end

    factory 'has_many field' do
      type        { 'has_many' }
      class_name  { 'Locomotive::ContentType42' }
      inverse_of  { 'somefield' }
      order_by    { 'someotherfield' }
      ui_enabled  { true }
    end

  end

end
