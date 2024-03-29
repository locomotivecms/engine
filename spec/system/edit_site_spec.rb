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
 
  it 'does not leak locales into input\'s value' do
    click_button 'Save'
    click_link 'SEO'
    expect(page).not_to have_field('site_seo_title', with: 'en ')
  end
end
