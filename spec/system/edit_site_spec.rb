describe 'Editing a site' do

  before do
    create_full_site
    click_link 'Site Administration'
  end

  it 'edits it with success' do
    fill_in 'Name', with: 'Acme!'
    click_button 'Save'
    expect(page).to have_content('My site was successfully updated.')
  end

end
