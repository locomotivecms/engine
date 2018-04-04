describe 'A site with content entries' do

  before { create_full_site }

  describe 'User edits their account' do

    it 'by changing their email without providing current password', js: true do
      navigate_to_credentials
      fill_in 'Email', with: 'new@email.com'
      click_button 'Save'
      expect(page).to have_content("CAN'T BE BLANK")
    end

    it 'by changing their email and provides current password', js: true do
      navigate_to_credentials
      fill_in 'Email', with: 'new@email.com'
      fill_in 'Current password', with: 'easyone'
      click_button 'Save'
      expect(page).to have_content('My account was successfully updated')
    end

    it 'by changing their password without providing current password', js: true do
      navigate_to_credentials
      fill_in 'Email', with: 'new@email.com'
      fill_in 'New password', with: 'newpassword'
      fill_in 'New password confirmation', with: 'newpassword'
      click_button 'Save'
      expect(page).to have_content("CAN'T BE BLANK")
    end

    it 'by changing their password and provides current password', js: true do
      navigate_to_credentials
      fill_in 'Email', with: 'new@email.com'
      fill_in 'Current password', with: 'easyone'
      fill_in 'New password', with: 'newpassword'
      fill_in 'New password confirmation', with: 'newpassword'
      click_button 'Save'
      expect(page).to have_content('Sign in')
    end

  end

  def navigate_to_credentials
    find('#navigation-dropdown').click
    click_link 'Account settings', visible: false
    click_link 'Credentials'
  end

end
