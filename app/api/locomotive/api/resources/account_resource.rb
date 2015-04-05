module Locomotive
  module API
    module Resources

      class AccountResource < Grape::API

        resource :accounts do
          entity_klass = Entities::AccountEntity

          before do
            setup_resource_methods_for(:accounts)
          end

          desc 'Index of accounts'
          get :index do
            authenticate_locomotive_account!
            authorize accounts, :index?

            present accounts, with: entity_klass
          end

          desc 'Show an account'
          params do
            requires :id, type: String, desc: 'Account ID'
          end
          route_param :id do
            get do
              authenticate_locomotive_account!
              authorize account, :show?

              present account, with: entity_klass
            end
          end

          desc 'Create an account'
          params do
            requires :account, type: Hash do
              requires :name
              requires :email
              requires :password
              requires :password_confirmation
            end
          end
          post do
            authorize Account, :create?
            form = form_klass.new(account_params)
            persist_from_form(form)

            present account, with: entity_klass
          end

          desc 'Update an account'
          params do
            requires :account, type: Hash do
              optional :name
              optional :email
              optional :password
              optional :password_confirmation
              optional :locale
              optional :api_key
              optional :super_admin
            end
          end
          put ':id' do
            authenticate_locomotive_account!
            authorize account, :update?

            form = form_klass.new(account_params)
            persist_from_form(form)

            present account, with: entity_klass
          end

          desc 'Delete an account'
          params do
            requires :id, type: String, desc: 'Account ID'
          end
          delete ':id' do
            authenticate_locomotive_account!
            authorize account, :destroy?

            account.destroy

            present account, with: entity_klass
          end

        end

      end

    end
  end
end
