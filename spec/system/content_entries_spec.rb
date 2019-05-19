describe 'A site with content entries' do

  before { create_full_site }

  describe 'content types with relationships' do

    it 'creates an article and attach a photo to it', js: true do
      click_link 'Models'
      click_link 'Article'
      click_link 'New entry'
      fill_in 'Title', with: 'Hello world'
      within('#main') { click_button 'Create' }
      expect(page).to have_content('Entry was successfully created.')
      click_link 'Add a new one'
      fill_in 'Title', with: 'First photo'
      within('#main') { click_button 'Create' }
      expect(page).to have_content('Entry was successfully created.')
      expect(page).to have_content('Articles — editing entry')
    end

  end

  describe 'content type with public_submission enabled' do

    it 'adds accounts', js: true do
      click_link 'Models'
      click_link 'Messages'
      click_button 'Toggle Dropdown'
      click_link 'Edit notification settings'
      expect(page).to have_content('NOTIFIED ACCOUNTS')
    end

  end

end
