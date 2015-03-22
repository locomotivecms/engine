module Locomotive
  module Resources
    class AccountAPI < Grape::API

      resource :accounts do
        entity_klass = Locomotive::AccountEntity

        before do
          setup_resource_methods_for(:accounts)
          authenticate_locomotive_account!
        end

        desc 'Index of accounts'
        get :index do
          authorize accounts, :index?

          present accounts, with: entity_klass
        end


        desc 'Show an account'
        params do
          requires :id, type: String, desc: 'Account ID'
        end
        route_param :id do
          get do
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
            optional :super_admin, type: Boolean
          end
        end
        put ':id' do
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
          authorize account, :destroy?

          account.destroy

          present account, with: entity_klass
        end

      end

    end
  end
end
