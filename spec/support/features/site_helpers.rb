module Features
  module SiteHelpers

    def create_full_site
      # 1. create site
      sign_in
      click_link 'Add a new site'
      fill_in 'Name', with: 'Acme'
      click_button 'Create'
      @site = Locomotive::Site.where(name: 'Acme').first

      # 2. add content types
      create('message content type', site: @site, public_submission_enabled: true)
      articles  = create('article content type', slug: 'articles', site: @site)
      photos    = create('photo content type', slug: 'photos', site: @site)

      # create relationships
      photos.entries_custom_fields.build(label: 'Article', name: 'article', type: 'belongs_to', class_name: articles.entries_class_name)
      photos.save!
      articles.entries_custom_fields.build(label: 'Photos', name: 'photos', type: 'has_many', class_name: photos.entries_class_name, inverse_of: 'article')
      articles.save!

      click_link 'Dashboard'
    end

  end
end
