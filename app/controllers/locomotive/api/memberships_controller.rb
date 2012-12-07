module Locomotive
  module Api
    class MembershipsController < BaseController

      load_and_authorize_resource class: Locomotive::Membership, through: :current_site

      def index
        respond_with(@memberships)
      end

      def show
        respond_with(@membership)
      end

      def create
        @membership.from_presenter(params[:membership].merge(role: 'author')) # force author by default
        @membership.save
        respond_with(@membership)
      end

      def update
        @membership.from_presenter(params[:membership])
        @membership.save
        respond_with(@membership)
      end

      def destroy
        @membership.destroy
        respond_with(@membership)
      end

      protected

      def self.description
        {
          overall: %{Manage the memberships of an account for the current site},
          actions: {
            index: {
              description: %{Return all the memberships of the current site},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/memberships.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of a membership},
              response: Locomotive::MembershipPresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/memberships/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a membership},
              params: Locomotive::MembershipPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/memberships.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a membership},
              params: Locomotive::MembershipPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/memberships/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete a membership},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/memberships/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

    end

  end
end

