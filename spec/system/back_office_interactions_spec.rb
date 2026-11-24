# Interactions bound with jQuery in the back-office.
describe 'Back-office interactions', js: true do

  before { create_full_site }

  it 'marks the hovered form field' do
    visit "/locomotive/#{@site.handle}/current_site/edit"
    find('.form-group.input', match: :first).hover
    expect(page).to have_css('.form-group.input.hovered')
    find('.public-box, .main', match: :first).hover rescue nil
    expect(page).to have_no_javascript_error
  end

end
