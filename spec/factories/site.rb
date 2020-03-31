# encoding: utf-8

FactoryBot.define do

  ## Site ##
  factory :site, class: Locomotive::Site do
    name { 'Acme Website' }
    handle { 'acme' }
    # sequence(:handle) { |n| "acme#{n*rand(10_000)}" }
    created_at { Time.now }

    factory 'test site' do
      name { 'Locomotive test website' }
      handle { 'test' }

      after(:build) do |site_test|
        site_test.memberships.build account: Locomotive::Account.where(name: 'Admin').first || create('admin user'), role: 'admin'
      end

      factory 'another site' do
        name { 'Locomotive test website #2' }
        handle { 'test2' }
      end

    end

    factory 'existing site' do
      name { 'Locomotive site with existing models' }
      handle { 'models' }
      after(:build) do |site_with_models|
        site_with_models.content_types.build(
          slug: 'projects',
          name: 'Existing name',
          description: 'Existing description',
          order_by: 'created_at')
      end

    end

    trait :with_custom_smtp_settings do
      metafields_schema { [
        {
          'name' => 'mailer_settings',
          'fields' => [
            { 'name' => 'address' },
            { 'name' => 'authentication' },
            { 'name' => 'port', 'type' => 'integer' },
            { 'name' => 'enable_starttls_auto', 'type' => 'boolean' },
            { 'name' => 'user_name' },
            { 'name' => 'password' },
            { 'name' => 'domain' },
            { 'name' => 'from' }
          ]
        }
      ] }
    end

    factory 'valid site' do
      # after(:build) { |valid_site| valid_site.stubs(:valid?).returns(true) }
    end

  end

end
