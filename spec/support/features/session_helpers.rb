module Features
  module SessionHelpers

    def sign_up_with(name, email, password, password_confirmation = nil)
      visit locomotive.sign_up_path
      fill_in 'Name', with: name
      fill_in 'Email', with: email
      fill_in 'locomotive_account[password]', with: password
      fill_in 'locomotive_account[password_confirmation]', with: password_confirmation || password
      click_button 'Sign up'
    end

    def sign_in
      account = create(:account)
      visit locomotive.new_locomotive_account_session_path
      fill_in 'Email', with: account.email
      fill_in 'Password', with: account.password
      click_button 'Sign in'
    end
  end
end
