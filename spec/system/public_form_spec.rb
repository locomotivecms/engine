describe 'A site with a form content type' do

  before { create_full_site }

  describe 'it submits the form in HTML' do

    before { preview_page 'contact' }

    it 'with valid inputs' do
      fill_in 'content[name]', with: 'John Doe'
      fill_in 'content[message]', with: 'Hello world'
      click_button 'Send'

      entry = @site.content_entries.last
      expect(entry.name).to eq 'John Doe'
      expect(entry.message).to eq 'Hello world'

      expect(page).to have_content('Content of the home page')
    end

    it 'with missing inputs' do
      fill_in 'content[message]', with: 'Hello world'
      click_button 'Send'

      expect(@site.content_types.where(slug: 'messages').first.entries.count).to eq 0
      expect(page).to have_content('num errors: 1')
      expect(page).to have_content("-name can't be blank-")
    end

  end

end
