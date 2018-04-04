describe 'User resets her/his password' do

  it 'with valid email and password', js: true  do
    forgot_password do |email, url|
      expect(email.to).to include 'john@doe.net'
      expect(email.subject).to include 'Reset password instructions'

      visit url
      fill_in 'Your new password', with: 'newpassword'
      fill_in 'Confirm password', with: 'newpassword'
      click_button 'Update my password'
      expect(page).to have_content('Your password was changed successfully. You are now signed in.')
    end
  end

  it 'with not matching password and password confirmation' do
    forgot_password do |_, url|
      visit url
      fill_in 'Your new password', with: 'a'
      fill_in 'Confirm password', with: 'b'
      click_button 'Update my password'
      expect(page).to have_content("DOESN'T MATCH PASSWORD")
    end
  end

  it 'with empty new password' do
    forgot_password do |_, url|
      visit url
      fill_in 'Your new password', with: ''
      fill_in 'Confirm password', with: ''
      click_button 'Update my password'
      expect(page).to have_content("CAN'T BE BLANK")
    end
  end

end
