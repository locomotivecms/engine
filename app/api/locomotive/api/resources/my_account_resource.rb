module Locomotive
  module API
    module Resources

      class MyAccountResource < Grape::API

        resource :my_account do

          entity_klass = Entities::AccountEntity

          helpers do
            def must_not_be_logged_in
              raise Pundit::NotAuthorizedError.new('You must not be logged in') if current_account
            end
          end

          desc 'Show my account'
          get do
            authenticate_locomotive_account!
            present current_account, with: entity_klass
          end

          desc 'Update my account'
          params do
            requires :account, type: Hash do
              optional :name
              optional :email
              optional :locale
              optional :encrypte_password
              optional :password_salt
              optional :password
              optional :password_confirmation
            end
          end
          put do
            authenticate_locomotive_account!
            my_account = current_account
            authorize my_account, :update?

            my_account_form = Forms::MyAccountForm.new(permitted_params[:account])
            my_account.assign_attributes(my_account_form.serializable_hash)
            my_account.save!

            present my_account, with: entity_klass
          end


          desc 'Create account'
          params do
            requires :account, type: Hash do
              requires :name
              requires :email
              requires :password
              optional :password_confirmation
              optional :locale
            end
          end
          post do
            must_not_be_logged_in

            my_account_form = Forms::MyAccountForm.new(permitted_params[:account])
            my_account = Account.create!(my_account_form.serializable_hash)

            present my_account, with: entity_klass
          end

        end
      end

    end
  end
end
