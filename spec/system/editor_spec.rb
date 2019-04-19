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

end

