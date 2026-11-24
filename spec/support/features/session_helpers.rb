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
      # wait for each page before acting on the next one; a click during a redirect gets lost
      expect(page).to have_content('My sites')
      click_link 'John Doe'
      within('.navigation') { click_link 'Log out' }
      expect(page).to have_current_path(locomotive.new_locomotive_account_session_path)
      click_link 'Forgot my password'
      fill_in 'Your email', with: 'john@doe.net'
      expect(page).to have_field('Your email', with: 'john@doe.net')
      click_button 'Submit'
      expect(page).to have_current_path(locomotive.new_locomotive_account_session_path) # devise redirects once the mail is sent

      if block_given?
        # the mail may arrive a bit after the request; wait for it instead of a fixed sleep
        last_email = nil
        Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.1 until (last_email = ActionMailer::Base.deliveries.last) }
        last_email.body.to_s =~ /<a href="http:\/\/locomotive.local:9886(\S+)">/
        yield last_email, $1
      end
    end

  end
end
