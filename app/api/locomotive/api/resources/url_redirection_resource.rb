module Locomotive
  module API
    module Resources

      class UrlRedirectionResource < Grape::API

        resource :url_redirections do
          entity_klass = Entities::SiteEntity

          before do
            authenticate_locomotive_account!
            require_site!
          end

          desc 'Index of url redirections'
          get '/' do
            authorize current_site, :show?

            present current_site.url_redirections_with_information, with: Grape::Presenters::Presenter
          end


          desc 'Add or update url redirection'
          params do
            requires :url_redirection, type: Hash do
              requires :source
              requires :target
              optional :counter, type: Integer
              optional :hidden, type: Boolean
            end
          end
          put do
            authorize current_site, :update?

            source      = params[:url_redirection][:source]
            target      = params[:url_redirection][:target]
            information = params[:url_redirection].slice(:counter, :hidden)

            if current_site.add_or_update_url_redirection(source, target, information)
              current_site.save
              present current_site, with: Grape::Presenters::Presenter
            else
              status 422
            end
          end


          desc "Delete url redirection"
          params do
            requires :url_redirection, type: Hash do
              requires :source
            end
          end
          delete do
            authorize current_site, :destroy?

            current_site.remove_url_redirection(params[:url_redirection][:source])
            current_site.save

            present current_site, with: entity_klass
          end

        end
      end

    end

  end
end
