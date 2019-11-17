require 'spec_helper'

describe Locomotive::API::Resources::AccountResource do

  include_context 'api site setup'

  let(:params) { { locale: :en } }
  let(:url_prefix) { '/locomotive/api/v3/accounts' }
  let!(:new_account) { create(:account, email: 'abc@example.com', name: 'Lisa Johnson') }

  context 'authenticated site as super admin' do
    include_context 'api header setup without a site'
    let(:account) { create(:account, super_admin: true) }

    describe 'GET index' do
      context 'JSON' do
        before { get "#{url_prefix}.json" }

        it 'returns a successful response' do
          expect(last_response).to be_successful
        end

        it 'returns an array' do
          expect(parsed_response).to be_kind_of(Array)
        end

      end
    end

    describe 'GET show' do
      context 'JSON' do
        before { get "#{url_prefix}/#{account.id}.json" }

        it 'returns the spec account' do
          expect(parsed_response[:name]).to eq(account.name)
        end
      end
    end

    describe 'POST create' do
      context 'JSON' do
        let(:new_account) do
          attributes_for('account').tap do |_account|
            _account[:name] = 'Homer Simpson'
            _account[:email] = 'homer@example.com'
          end
        end

        it 'creates the account' do
          expect{ post("#{url_prefix}.json", account: new_account) }
            .to change{ Locomotive::Account.count }.by(1)
        end

        it 'does not set super_admin on create' do
          new_account.merge!(super_admin: true)
          post("#{url_prefix}.json", account: new_account)

          expect(last_response[:super_admin]).to be_falsy
        end
      end
    end

    describe 'PUT update' do
      context 'JSON' do
        let(:updated_account_params) { { name: 'Maggie Anderson' } }
        let(:put_request) do
          put "#{url_prefix}/#{account.id}.json", account: updated_account_params
        end

        it 'changes the account name' do
          expect{ put_request }.to change{ account.reload.name }.to('Maggie Anderson')
        end

        context 'setting super admin' do
          let(:put_request) do
            put("#{url_prefix}/#{new_account.id}.json", account: updated_account_params)
          end

          it 'sets super admin on the new account' do
            updated_account_params.merge!(super_admin: true)
            expect{ put_request }.to change{ new_account.reload.super_admin }
              .from(false).to(true)
          end
        end

      end
    end

    describe 'DELETE destroy' do
      context 'JSON' do
        let(:delete_request) { delete("#{url_prefix}/#{new_account.id}.json")}

        it 'deletes the account' do
          expect{ delete_request }.to change { Locomotive::Account.count }.by(-1)
        end
      end
    end

  end

end
