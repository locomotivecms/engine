require 'spec_helper'

describe 'User signs up' do

  it 'with valid email and password', js: true  do
    sign_up_with 'John Doe', 'john@doe.net', 'password'
    expect(page).to have_content('My sites')
    expect(page).to have_content('You have signed up successfully.')
  end

  it 'with invalid email' do
    sign_up_with 'John Doe', 'invalid_email', 'password'
    expect(page).to have_content('Already have an account?')
    expect(page).to have_content('is invalid')
  end

  it 'with blank password' do
    sign_up_with 'John Doe', 'valid@example.com', ''
    expect(page).to have_content('Already have an account?')
    expect(page).to have_content("can't be blank")
  end

  it 'with not matching passwords' do
    sign_up_with 'John Doe', 'valid@example.com', 'password', ''
    expect(page).to have_content('Already have an account?')
    expect(page).to have_content("doesn't match Password")
  end

end
