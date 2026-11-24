describe 'A site with sections' do

  before { create_full_site }

  describe 'editing a section of a page' do

    it 'modifies the content of a section', js: true do
      click_link 'Pages'
      click_link 'Hello world'
      expect(page).to have_content('/hello-world')
      click_link 'This is the header'
      expect(page).to have_no_javascript_error
      expect(page).to have_content('TITLE')
      fill_in 'Title', with: 'My new header'
      click_button 'Save'
      expect(page).to have_content('Saving...')
    end

  end

  describe 'following a link in the preview' do

    it 'shows the loader and then edits the linked page', js: true do
      # a <head> is needed: steam puts the page id meta tags the editor reads in there
      @site.pages.create!(
        parent: @site.pages.root.first, title: 'Target', slug: 'target',
        raw_template: %{<html><head></head><body>{% section 'header' %}</body></html>}
      )
      linker = @site.pages.create!(
        parent: @site.pages.root.first, title: 'Linker', slug: 'linker',
        raw_template: %{<html><head></head><body>{% section 'header' %}<a href="/target">Go to target</a></body></html>},
        sections_content: { header: { settings: { title: 'Linker header' } } }
      )
      visit "/locomotive/#{@site.handle}/pages/#{linker._id}/content/edit"
      expect(page).to have_content('/linker')

      within_frame(find('.preview-iframe iframe')) { click_link 'Go to target' }

      # the editor hears the iframe leaving its page (pagehide) and shows the loader
      expect(page).to have_css('.preview-iframe-loader')
      expect(page).to have_content('/target')
      expect(page).to have_no_css('.preview-iframe-loader')
      expect(page).to have_no_javascript_error
    end

  end

end
