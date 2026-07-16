require 'spec_helper'

describe 'API token authentication' do

  include Rack::Test::Methods

  let(:my_account_url) { '/locomotive/api/v3/my_account.json' }

  def authenticate_as(email, token)
    header 'X-Locomotive-Account-Email', email
    header 'X-Locomotive-Account-Token', token
  end

  describe 'credential pair (GET /my_account)' do
    let!(:account) { create(:account) }
    let(:token)    { account.authentication_token }

    it 'accepts a valid email and token pair and identifies the account' do
      authenticate_as(account.email, token)
      get my_account_url
      expect(last_response.status).to eq 200
      expect(parsed_response[:email]).to eq(account.email)
    end

    it 'identifies each account by its own pair' do
      other = create(:account)
      authenticate_as(other.email, other.authentication_token)
      get my_account_url
      expect(last_response.status).to eq 200
      expect(parsed_response[:email]).to eq(other.email)
    end

    it 'rejects a request with no credential headers with 401' do
      get my_account_url
      expect(last_response.status).to eq 401
    end

    it 'rejects a request with both credential headers blank with 401' do
      authenticate_as('', '')
      get my_account_url
      expect(last_response.status).to eq 401
    end

    it 'ignores a stale unsafe flag and rejects the legacy auth_token parameter' do
      Locomotive.config.unsafe_token_authentication = true

      get "#{my_account_url}?auth_token=#{account.authentication_token}"

      expect(last_response.status).to eq 401
    ensure
      Locomotive::Configuration.settings.delete(:unsafe_token_authentication)
    end

    context 'with a valid token but the wrong email' do
      it 'rejects a missing email with 401' do
        header 'X-Locomotive-Account-Token', token
        get my_account_url
        expect(last_response.status).to eq 401
      end

      it 'rejects a blank email with 401' do
        authenticate_as('', token)
        get my_account_url
        expect(last_response.status).to eq 401
      end

      it 'rejects an unknown email with 401' do
        authenticate_as('nobody@example.com', token)
        get my_account_url
        expect(last_response.status).to eq 401
      end
    end

    context 'with a valid email but the wrong token' do
      it 'rejects a missing token with 401' do
        header 'X-Locomotive-Account-Email', account.email
        get my_account_url
        expect(last_response.status).to eq 401
      end

      it 'rejects a blank token with 401' do
        authenticate_as(account.email, '')
        get my_account_url
        expect(last_response.status).to eq 401
      end

      it 'rejects an unknown token with 401' do
        authenticate_as(account.email, 'nope')
        get my_account_url
        expect(last_response.status).to eq 401
      end
    end

    it 'rejects one account email paired with another account token' do
      other = create(:account)
      authenticate_as(account.email, other.authentication_token)
      get my_account_url
      expect(last_response.status).to eq 401
    end
  end

  describe 'tenant scope (site-scoped endpoints require a membership)' do
    let!(:site)          { create(:site) }
    let!(:member)        { create(:account) }
    let!(:_membership)   { create(:admin, account: member, site: site, role: 'admin') }
    let!(:other_site)    { create(:site, handle: 'tenant_b') }
    let!(:outsider)      { create(:account) }
    let!(:_outsider_mem) { create(:admin, account: outsider, site: other_site, role: 'admin') }
    let!(:super_admin)   { create(:account, super_admin: true) }
    let!(:content_type)  { create(:content_type, :article, site: site) }
    let!(:page)          { create(:page, :index, site: site) }

    let(:current_site_path) { "/locomotive/#{site.handle}/api/v3/current_site.json" }
    let(:page_path)         { "/locomotive/#{site.handle}/api/v3/pages/#{page.id}.json" }
    let(:content_type_path) { "/locomotive/#{site.handle}/api/v3/content_types/#{content_type.id}.json" }

    def read_status(account, path)
      authenticate_as(account.email, account.authentication_token)
      get path
      last_response.status
    end

    context 'an account with no membership to the site' do
      it 'is rejected from current_site with 401' do
        expect(read_status(outsider, current_site_path)).to eq 401
      end

      it 'is rejected from a non-hidden page with 401' do
        expect(read_status(outsider, page_path)).to eq 401
      end

      it 'is rejected from a non-hidden content type with 401' do
        expect(read_status(outsider, content_type_path)).to eq 401
      end
    end

    it 'lets a member of the site read current_site' do
      expect(read_status(member, current_site_path)).to eq 200
    end

    it 'lets a super admin without a membership read current_site' do
      expect(read_status(super_admin, current_site_path)).to eq 200
    end
  end

end
