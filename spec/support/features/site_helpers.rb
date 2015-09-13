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
      @content_type = create('message content type', site: @site, public_submission_enabled: true)

      click_link 'Dashboard'
    end

  end
end
