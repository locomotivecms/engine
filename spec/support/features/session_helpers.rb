module Features
  module SessionHelpers

    def sign_up_with(name, email, password, password_confirmation = nil)
      visit '/locomotive/sign_up'
      fill_in 'Name', with: name
      fill_in 'Email', with: email
      fill_in 'locomotive_account[password]', with: password
      fill_in 'locomotive_account[password_confirmation]', with: password_confirmation || password
      click_button 'Sign up'
    end

    # def sign_in
    #   user = create(:user)
    #   visit sign_in_path
    #   fill_in 'Email', with: user.email
    #   fill_in 'Password', with: user.password
    #   click_button 'Sign in'
    # end
  end
end
