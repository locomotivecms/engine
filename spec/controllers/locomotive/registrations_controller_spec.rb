describe Locomotive::RegistrationsController do

  routes { Locomotive::Engine.routes }

  before do
    request.env['devise.mapping'] = Devise.mappings[:locomotive_account]
  end

  describe "#POST create" do
    let(:account_attributes) do
      { name: 'Elon', email: 'elon@spacex.com', password: 'easyone', password_confirmation: 'easyone' }
    end
    subject do
      post :create, params: { locomotive_account: account_attributes }
    end
    it { is_expected.to redirect_to sites_path }
    specify do
      expect { subject }.to change(Locomotive::Account, :count)
    end
  end

end
