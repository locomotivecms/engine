shared_context 'api site setup' do
  include Rack::Test::Methods
  let!(:site) { create(:site, domains: %w{www.acme.com}, locales: %w(en fr)) }

  let!(:account) { create(:account) }
  let(:params) { { locale: :en } }

  let!(:membership) do
    create(:admin, account: account, site: site, role: 'admin')
  end

  subject { parsed_response }
end
