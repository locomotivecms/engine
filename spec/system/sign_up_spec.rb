describe 'User signs up' do

  it 'with valid email and password'  do
    sign_up_with 'John Doe', 'john@doe.net', 'password'
    expect(page).to have_content('My sites')
    expect(page).to have_content('You have signed up successfully.')
  end

  it 'with invalid email' do
    sign_up_with 'John Doe', 'invalid_email', 'password'
    expect(page).to have_content('Already have an account?')
    message = page.find("#locomotive_account_email").native.attribute("validationMessage")
    expect(message).to eq "Please include an '@' in the email address. 'invalid_email' is missing an '@'."
  end

  it 'with blank password' do
    sign_up_with 'John Doe', 'valid@example.com', ''
    expect(page).to have_content('Already have an account?')
    message = page.find("#locomotive_account_password").native.attribute("validationMessage")
    expect(message).to eq "Please fill out this field."
  end

  it 'with not matching passwords' do
    sign_up_with 'John Doe', 'valid@example.com', 'password', 'anotherpassword'
    expect(page).to have_content('Already have an account?')
    expect(page).to have_content("DOESN'T MATCH PASSWORD")
  end

  context 'registration disabled' do

    before { allow(Locomotive.config).to receive(:enable_registration).and_return(false) }

    it 'login screen does not show link to create account' do
      visit locomotive.sign_in_path
      expect(page).to_not have_content('Do not have an account?')
    end
  end

end
