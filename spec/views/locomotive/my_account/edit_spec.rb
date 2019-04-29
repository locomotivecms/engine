describe 'locomotive/my_account/edit', type: :view do

  helper(Locomotive::BaseHelper, Locomotive::Shared::AccountsHelper, Locomotive::MyAccountHelper, Locomotive::Engine.routes.url_helpers)
  helper(Locomotive::TestViewHelpers)

  let(:account) { build(:account, api_key: 42) }

  before {
    allow(view).to receive(:policy).and_return(instance_double('Policy', edit?: true))
    allow(view).to receive(:last_saved_location).and_return(nil)
    allow(view).to receive(:current_locomotive_account).and_return(account)
  }

  before do
    assign(:account, account)
  end

  subject { render }

  describe 'api_key input' do

    it 'renders the url to generate a new API key' do
      expect(subject).to include('<legend><span>api</span></legend>')
      expect(subject).to include('data-url="/locomotive/my_account/regenerate_api_key"')
    end

  end

  describe 'file input' do

    it 'renders a label for a new file' do
      expect(subject).to include('<span class="file-name">no file</span>')
    end

  end

  describe 'i18n' do

    it 'renders a localized label' do
      expect(subject).to include('<label class="control-label api_key optional" for="account_api_key">API key</label>')
    end

    it 'renders a localized hint' do
      expect(subject).to include('Used by Wagon to deploy your site (check your config/deploy.yml file of your Wagon site).')
    end

  end

   describe 'new password' do

    it 'renders an input for the current password' do
      expect(subject).to include('name="account[current_password]" id="account_current_password"')
    end

    it 'renders an input for a new password' do
      expect(subject).to include('name="account[password]" id="account_password"')
    end

    it 'renders an input for a new password confirmation' do
      expect(subject).to include('name="account[password_confirmation]" id="account_password_confirmation"')
    end

  end


end
