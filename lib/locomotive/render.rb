module Locomotive
  module Render

    extend ActiveSupport::Concern

    protected

    # Render a Locomotive page from the the current site and both the params[:page] / params[:page_path]
    # attributes OR the request fullpath if those params are not present.
    # If the page corresponds to a redirect, then a 301 or 302 redirection is made.
    # If the page is templatized, the target content entry is retrieved and attached to the
    # Liquid context.
    #
    # @param [ String ] path The path can be forced (optional)
    # @param [ Hash ] assigns The liquid context passed to the page can be enhanced by assigns coming from the controller for instance.
    #
    def render_locomotive_page(path = nil, assigns = {})
      if request.fullpath =~ /^\/#{Locomotive.mounted_on}\//
        render template: '/locomotive/errors/404', layout: '/locomotive/layouts/not_logged_in', status: :not_found
      else
        @page ||= self.locomotive_page(path)

        if @page.present? && @page.redirect?
          self.redirect_to_locomotive_page and return
        end

        render_no_page_error and return if @page.nil?

        output = @page.render(self.locomotive_context(assigns))

        self.prepare_and_set_response(output)
      end
    end

    # Redirect to the url given by the redirect_url field of the
    # Locomotive page. If we are in the editing mode, the "_edit" prefix
    # will be added as well.
    #
    def redirect_to_locomotive_page
      redirect_url = @page.redirect_url

      redirect_url = "#{redirect_url}/_edit" if self.editing_page?

      redirect_to(redirect_url, status: @page.redirect_type)
    end

    # Render the page which tells that no page exists.
    # This case should not happen since all the sites contains
    # the "Page Not Found" page.
    #
    def render_no_page_error
      render template: '/locomotive/errors/no_page', layout: false, status: 404, formats: [:html]
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
        fresh_when etag: @page, last_modified: @page.updated_at.utc, public: true

        if @page.cache_strategy != 'simple' # varnish
          response.headers['Editable']      = ''
          response.cache_control[:max_age]  = @page.cache_strategy
        end
      end

      render text: output, layout: false, status: page_status unless performed?
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
    # @param [ String ] path An optional path overriding the default behaviour to get a page
    #
    # @return [ Object ] The Locomotive::Page
    #
    def locomotive_page(path = nil)
      # TODO: params[:path] is more consistent
      path ||= (params[:path] || params[:page_path] || request.fullpath).clone

      path = self.sanitize_locomotive_page_path(path)

      current_site.fetch_page path, current_locomotive_account.present?
    end

    # Clean the path that can be understood by Locomotive in order to retrieve
    # the matching Locomotive page (see the locomotive_page method)
    #
    # @return [ String ] The path to the Locomotive page
    #
    def sanitize_locomotive_page_path(path)
      path = path.split('?').first # take everything before the query string or the lookup fails
      path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '') # remove the page extension
      path.gsub!(/^\//, '') # remove the leading slash

      path = 'index' if path.blank? || path == '_edit'

      path
    end

    # Build the Liquid context used to render the Locomotive page. It
    # stores both assigns and registers.
    #
    # @param [ Hash ] other_assigns Assigns coming for instance from the controler (optional)
    #
    # @return [ Object ] A new instance of the Liquid::Context class.
    #
    def locomotive_context(other_assigns = {})
      assigns = self.locomotive_default_assigns

      # proxy drops
      assigns.merge!(Locomotive.config.context_assign_extensions)

      # process data from the session
      assigns.merge!(self.locomotive_flash_assigns)

      assigns.merge!(other_assigns)

      if defined?(@page) && @page.templatized? # add instance from content type
        content_entry = @page.content_entry.to_liquid
        ['content_entry', 'entry', @page.target_entry_name].each do |key|
          assigns[key] = content_entry
        end
      end

      # Tip: switch from false to true to enable the re-thrown exception flag
      ::Liquid::Context.new({}, assigns, self.locomotive_default_registers, true)
    end

    # Get the assigns from the flash object (session). For instance, once
    # a new content entry has been submitted, the new instance is available
    # after redirecting the user to the success locomotive page.
    #
    # @return [ Hash ] The sanitized assigns from the flash object
    #
    def locomotive_flash_assigns
      assigns = flash.to_hash.stringify_keys

      if entry_id = assigns.delete('submitted_entry_id')
        entry = Locomotive::ContentEntry.find(entry_id) rescue nil

        if entry
          assigns[entry.content_type.slug.singularize] = entry.to_liquid
        end
      end

      assigns
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
        'ip_address'        => request.remote_ip,
        'post?'             => request.post?,
        'host'              => request.host_with_port,
        'now'               => Time.now.in_time_zone(current_site.timezone),
        'today'             => Date.today,
        'locale'            => I18n.locale.to_s,
        'default_locale'    => current_site.default_locale.to_s,
        'locales'           => current_site.locales,
        'current_user'      => Locomotive::Liquid::Drops::CurrentUser.new(current_locomotive_account),
        'session'           => Locomotive::Liquid::Drops::SessionProxy.new,
        'wagon'             => false,
        'editing'           => self.editing_page?
      }
    end

    # Return the default Liquid registers used inside the Locomotive Liquid context
    #
    # @return [ Hash ] The default liquid registers object
    #
    def locomotive_default_registers
      {
        controller:     self,
        site:           current_site,
        page:           @page,
        inline_editor:  self.editing_page?,
        logger:         Rails.logger,
        current_locomotive_account: current_locomotive_account
      }
    end

  end
end