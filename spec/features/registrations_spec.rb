require 'spec_helper'

describe 'User registration' do
  context 'registration enabled' do
    it 'login screen shows link to create account' do
      visit locomotive.sign_in_path
      expect(page).to have_content('Do not have a Fightin Texas Aggie account!?')
    end
  end

  context 'registration disabled' do

    before { allow(Locomotive.config).to receive(:enable_registration).and_return(false) }

    it 'login screen does not show link to create account' do
      visit locomotive.sign_in_path
      expect(page).to_not have_content('Do not have a Fightin Texas Aggie account!?')
    end
  end
end
