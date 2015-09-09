module Locomotive
  module API
    module Resources

      class MembershipResource < Grape::API

        resource :memberships do
          entity_klass = Entities::MembershipEntity

          before do
            setup_resource_methods_for(:memberships)
            authenticate_locomotive_account!
          end

          desc 'Index of memberships'
          get do
            authorize(memberships, :index?)

            present memberships, with: entity_klass
          end

          desc "Show a membership"
          params do
            requires :id, type: String, desc: 'Membership ID'
          end
          route_param :id do
            get do
              authorize(membership, :show?)

              present membership, with: entity_klass
            end
          end

          desc 'Create a membership'
          params do
            requires :membership, type: Hash do
              optional :role
              optional :account_id
              optional :account_email
            end
          end
          post do
            authorize Membership, :create?

            form = form_klass.new(current_site, membership_params)
            persist_from_form(form)

            present membership, with: entity_klass, policy: current_policy
          end

          desc 'Update a membership'
          params do
            requires :id, type: String, desc: 'Membership ID'
            requires :membership, type: Hash do
              optional :role
              optional :account_id
            end
          end
          put ':id' do
            authorize membership, :update?

            form = form_klass.new(current_site, membership_params)
            persist_from_form(form)

            present membership, with: entity_klass
          end

          desc "Delete a membership"
          params do
            requires :id, type: String, desc: 'Membership ID'
          end
          delete ':id' do
            authorize membership, :destroy?

            membership.destroy

            present membership, with: entity_klass
          end

        end

      end

    end
  end
end
