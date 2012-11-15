module Locomotive
  module Render

    extend ActiveSupport::Concern

    protected

    # Render a Locomotive page from the request fullpath and the current site.
    # If the page corresponds to a redirect, then a 301 redirection is made.
    #
    def render_locomotive_page
      if request.fullpath =~ /^\/#{Locomotive.mounted_on}\//
        render :template => '/locomotive/errors/404', :layout => '/locomotive/layouts/not_logged_in', :status => :not_found
      else
        @page = locomotive_page

        redirect_to(@page.redirect_url, :status => 301) and return if @page.present? && @page.redirect?

        render_no_page_error and return if @page.nil?

        output = @page.render(locomotive_context)

        self.prepare_and_set_response(output)
      end
    end

    # Render the page which tells that no page exists.
    # This case should not happen since all the sites contains
    # the "Page Not Found" page.
    #
    def render_no_page_error
      render :template => '/locomotive/errors/no_page', :layout => false
    end

    # Prepare and set the response object for the Locomotive page retrieved
    # from the path. The caching (with Varnish for instance) if defined is done here.
    # It is also here that the content type of the request is set (html or json).
    # Behind the scene, it just calls simply the Rails render method.
    #
    # @param [ String ] The rendered Locomotive page
    #
    def prepare_and_set_response(output)
      flash.discard

      response.headers['Content-Type']  = "#{@page.response_type}; charset=utf-8"
      response.headers['Editable']      = 'true' unless self.editing_page? || current_locomotive_account.nil?

      if @page.with_cache?
        fresh_when :etag => @page, :last_modified => @page.updated_at.utc, :public => true

        if @page.cache_strategy != 'simple' # varnish
          response.headers['Editable']      = ''
          response.cache_control[:max_age]  = @page.cache_strategy
        end
      end

      render :text => output, :layout => false, :status => page_status unless performed?
    end

    # Tell if the current Locomotive page is being edited.
    #
    # @return [ Boolean ] True if being edited.
    #
    def editing_page?
      !!@editing
    end

    # Get the symbol matching the status of the current Locomotive page.
    # It can be either :ok or :not_found (404)
    #
    # @return [ Symbol ] :ok if the page is not the "Page not found" one.
    #
    def page_status
      @page.not_found? ? :not_found : :ok
    end

    # Get the Locomotive page matching the request and scoped by the current Locomotive site
    #
    # @return [ Object ] The Locomotive::Page
    #
    def locomotive_page
      current_site.fetch_page self.locomotive_page_path, current_locomotive_account.present?
    end

    # Build the path that can be understood by Locomotive in order to retrieve
    # the matching Locomotive page (see the locomotive_page method)
    #
    # @return [ String ] The path to the Locomotive page
    #
    def locomotive_page_path
      path = (params[:path] || params[:page_path] || request.fullpath).clone # TODO: params[:path] is more consistent
      path = path.split('?').first # take everything before the query string or the lookup fails
      path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '') # remove the page extension
      path.gsub!(/^\//, '') # remove the leading slash

      path = 'index' if path.blank? || path == '_edit'

      path
    end

    # Build the Liquid context used to render the Locomotive page. It
    # stores both assigns and registers.
    #
    # @return [ Object ] A Liquid::Context object.
    #
    def locomotive_context
      assigns = self.locomotive_default_assigns

      assigns.merge!(Locomotive.config.context_assign_extensions)

      assigns.merge!(flash.to_hash.stringify_keys) # data from public submissions

      if defined?(@page) && @page.templatized? # add instance from content type
        content_entry = @page.content_entry.to_liquid
        ['content_entry', 'entry', @page.target_entry_name].each do |key|
          assigns[key] = content_entry
        end
      end

      # Tip: switch from false to true to enable the re-thrown exception flag
      ::Liquid::Context.new({}, assigns, self.locomotive_default_registers, false)
    end

    # Return the default Liquid assigns used inside the Locomotive Liquid context
    #
    # @return [ Hash ] The default liquid assigns object
    #
    def locomotive_default_assigns
      {
        'site'              => current_site.to_liquid,
        'page'              => @page,
        'models'            => Locomotive::Liquid::Drops::ContentTypes.new,
        'contents'          => Locomotive::Liquid::Drops::ContentTypes.new, # DEPRECATED
        'current_page'      => self.params[:page],
        'params'            => self.params,
        'path'              => request.path,
        'fullpath'          => request.fullpath,
        'url'               => request.url,
        'now'               => Time.now.utc,
        'today'             => Date.today,
        'locale'            => I18n.locale.to_s,
        'default_locale'    => current_site.default_locale.to_s,
        'locales'           => current_site.locales,
        'current_user'      => Locomotive::Liquid::Drops::CurrentUser.new(current_locomotive_account)
      }
    end

    # Return the default Liquid registers used inside the Locomotive Liquid context
    #
    # @return [ Hash ] The default liquid registers object
    #
    def locomotive_default_registers
      {
        :controller     => self,
        :site           => current_site,
        :page           => @page,
        :inline_editor  => self.editing_page?,
        :current_locomotive_account => current_locomotive_account
      }
    end

  end
end
