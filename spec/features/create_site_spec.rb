require 'spec_helper'

describe 'User creates a site' do

  before do
    sign_in
    click_link 'Add a new site'
  end

  it 'with valid information', js: true do
    fill_in 'Name', with: 'Acme'
    click_button 'Create'
    expect(page).to have_content('Site was successfully created.')
  end

  it 'with blank name'  do
    fill_in 'Name', with: ''
    click_button 'Create'
    expect(page).to have_content("can't be blank")
    expect(page).not_to have_content('Site was successfully created.')
  end

end
