module Locomotive
  class ContentEntryImpersonationsController < BaseController

    account_required & within_site

    def create
      if content_entry.with_authentication?
        # automatically sign in the entry
        session[:authenticated_entry_type]    = content_type.slug
        session[:authenticated_entry_id]      = content_entry.id.to_s

        # add a flag to notify that the sign in was done by impersonating the entry
        session[:authenticated_impersonation] = '1'

        # notify signed in
        notify(:signed_in, content_entry, request)
        redirect_to preview_url(current_site)
      else
        redirect_to content_entries_path(current_site, content_type.slug)
      end
    end

    private

    def content_type
      @content_type ||= current_site.content_types.where(slug: params[:slug]).first!
    end

    def content_entry
      @content_entry ||= content_type.entries.find(params[:content_entry_id])
    end

    def notify(action, entry, request)
        ActiveSupport::Notifications.instrument("steam.auth.#{action}",
          site:     current_site,
          entry:    entry,
          locale:   locale,
          request:  request
        )
    end

  end
end
