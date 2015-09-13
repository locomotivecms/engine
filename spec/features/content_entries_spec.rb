require 'spec_helper'

describe 'A site with content entries' do

  before do
    create_full_site
    click_link 'Messages'
  end

  context 'public_submission_enabled' do

    it 'adds accounts', js: true do
      click_link 'Edit notification settings'
      expect(page).to have_content('NOTIFIED ACCOUNTS')
    end

  end

end
