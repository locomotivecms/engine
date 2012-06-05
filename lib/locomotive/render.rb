module Locomotive
  module Render

    extend ActiveSupport::Concern

    protected

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

    def render_no_page_error
      render :template => '/locomotive/errors/no_page', :layout => false
    end

    def locomotive_page
      current_site.fetch_page self.locomotive_page_path, current_locomotive_account.present?
    end

    def locomotive_page_path
      path = (params[:path] || params[:page_path] || request.fullpath).clone # TODO: params[:path] is more consistent
      path = path.split('?').first # take everything before the query string or the lookup fails
      path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '') # remove the page extension
      path.gsub!(/^\//, '') # remove the leading slash

      path = 'index' if path.blank? || path == '_edit'

      path
    end

    def locomotive_context
      assigns = {
        'site'              => current_site,
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

      assigns.merge!(Locomotive.config.context_assign_extensions)

      assigns.merge!(flash.to_hash.stringify_keys) # data from public submissions

      if @page.templatized? # add instance from content type
        assigns['content_entry'] = assigns['entry'] = @page.content_entry
        assigns[@page.target_entry_name] = @page.content_entry # just here to help to write readable liquid code
      end

      registers = {
        :controller     => self,
        :site           => current_site,
        :page           => @page,
        :inline_editor  => self.editing_page?,
        :current_locomotive_account => current_locomotive_account
      }

      ::Liquid::Context.new({}, assigns, registers, false) # switch from false to true to enable the re-thrown exception flag
    end

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

    def editing_page?
      !!@editing
    end

    def page_status
      @page.not_found? ? :not_found : :ok
    end

  end
end
