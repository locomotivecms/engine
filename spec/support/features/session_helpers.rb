module Features
  module SessionHelpers

    def sign_up_with(name, email, password, password_confirmation = nil)
      visit locomotive.sign_up_path
      fill_in 'Name', with: name
      fill_in 'Email', with: email
      fill_in 'locomotive_account[password]', with: password
      fill_in 'locomotive_account[password_confirmation]', with: password_confirmation || password
      click_button 'Register'
    end

    def sign_in
      @account = create(:account)
      visit locomotive.new_locomotive_account_session_path
      fill_in 'Email', with: @account.email
      fill_in 'Password', with: @account.password
      click_button 'Sign in'
    end

    def forgot_password(&block)
      sign_up_with 'John Doe', 'john@doe.net', 'password'
      click_link 'John Doe'
      within('.navigation') { click_link 'Log out' }
      click_link 'Forgot my password'
      expect(page).to have_field('Your email')
      fill_in 'Your email', with: 'john@doe.net'
      click_button 'Submit'
      # Devise redirects back to the sign in page once the e-mail has been sent;
      # waiting on that state guarantees the request (and delivery) completed.
      expect(page).to have_css('body.sessions')

      if block_given?
        last_email = ActionMailer::Base.deliveries.last
        last_email.body.to_s =~ /<a href="http:\/\/locomotive.local:9886(\S+)">/
        yield last_email, $1
      end
    end

  end
end
