module Features
  module SiteHelpers

    def create_full_site
      # 1. create site
      sign_in
      click_link 'Add a new site'
      fill_in 'Name', with: 'Acme'
      click_button 'Create'

      sleep(1)

      @site = Locomotive::Site.where(name: 'Acme').first

      # 2. add content types
      messages  = create('message content type', site: @site)
      articles  = create('article content type', slug: 'articles', site: @site)
      photos    = create('photo content type', slug: 'photos', site: @site)

      # create relationships
      photos.entries_custom_fields.build(label: 'Article', name: 'article', type: 'belongs_to', class_name: articles.entries_class_name)
      photos.save!
      articles.entries_custom_fields.build(label: 'Photos', name: 'photos', type: 'has_many', class_name: photos.entries_class_name, inverse_of: 'article')
      articles.save!

      # 3. create sections
      create(:section, site: @site) # Header
      create(:section, :gallery, site: @site) # Gallery of images

      # 4. create pages
      @site.pages.create(parent: @site.pages.home.first, title: 'Contact', slug: 'contact', raw_template: %{<html><body>{% if message.errors %}num errors: {{ message.errors.size }} / {% for error in message.errors %}-{{error[0]}} {{error[1]}}-{% endfor %}{% endif %}{% model_form 'messages', success: '/', error: '/contact' %}<input type="text" name="content[name]" value="{{customer_message.name}}"><input type="text" name="content[message]" value="{{customer_message.message}}"><input type="submit" value="Send">{% endmodel_form %}</body></html>})
      @site.pages.create(
        parent: @site.pages.home.first,
        title: 'Hello world',
        slug: 'hello-world',
        raw_template: %{<html><body>{% section 'header' %} {% section 'gallery' %}</body></html>},
        sections_content: {
          header: { settings: { title: 'This is the header' } },
          gallery: { settings: {}, blocks: [
            { type: 'image', settings: { image: '/images/ocean.jpg' } },
            { type: 'image', settings: { image: '/images/ocean.jpg' } },
            { type: 'image', settings: { image: '/images/ocean.jpg' } }
          ] }
        }
      )

      click_link 'Dashboard'
    end

    def preview_page(path = '')
      visit "/locomotive/#{@site.handle}/preview/#{path}"
    end

  end
end
