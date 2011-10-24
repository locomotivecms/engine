module Locomotive
  module Render

    extend ActiveSupport::Concern

    module InstanceMethods

      protected

      def render_locomotive_page
        if request.fullpath =~ /^\/admin\//
          render :template => '/admin/errors/404', :layout => '/admin/layouts/box', :status => :not_found
        else
          @page = locomotive_page

          redirect_to(@page.redirect_url) and return if @page.present? && @page.redirect?

          render_no_page_error and return if @page.nil?

          output = @page.render(locomotive_context)

          self.prepare_and_set_response(output)
        end
      end

      def render_no_page_error
        render :template => '/admin/errors/no_page', :layout => false
      end

      def locomotive_page
        path = (params[:path] || request.fullpath).clone # TODO: params[:path] is more consistent
        path = path.split('?').first # take everything before the query string or the lookup fails
        path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '') # remove the page extension
        path.gsub!(/^\//, '') # remove the leading slash

        path = 'index' if path.blank?

        if path != 'index'
          dirname = File.dirname(path).gsub(/^\.$/, '') # also look for templatized page path
          path = [path, File.join(dirname, 'content_type_template').gsub(/^\//, '')]
        end

        if page = current_site.pages.any_in(:fullpath => [*path]).first
          if not page.published? and current_admin.nil?
            page = nil
          else
            if page.templatized?
              @content_instance = page.content_type.contents.where(:_slug => File.basename(path.first)).first

              if @content_instance.nil? || (!@content_instance.visible? && current_admin.nil?) # content instance not found or not visible
                page = nil
              end
            end
          end
        end

        page || not_found_page
      end

      def locomotive_context
        assigns = {
          'site'              => current_site,
          'page'              => @page,
          'asset_collections' => Locomotive::Liquid::Drops::AssetCollections.new, # depracated, will be removed shortly
          'contents'          => Locomotive::Liquid::Drops::Contents.new,
          'current_page'      => self.params[:page],
          'params'            => self.params,
          'path'              => request.path,
          'url'               => request.url,
          'now'               => Time.now.utc,
          'today'             => Date.today
        }

        assigns.merge!(Locomotive.config.context_assign_extensions)

        assigns.merge!(flash.stringify_keys) # data from api

        if @page.templatized? # add instance from content type
          assigns['content_instance'] = @content_instance
          assigns[@page.content_type.slug.singularize] = @content_instance # just here to help to write readable liquid code
        end

        registers = {
          :controller     => self,
          :site           => current_site,
          :page           => @page,
          :inline_editor  => self.editing_page?,
          :current_admin  => current_admin
        }

        ::Liquid::Context.new({}, assigns, registers)
      end

      def prepare_and_set_response(output)
        flash.discard

        response.headers['Content-Type'] = 'text/html; charset=utf-8'

        if @page.with_cache?
          fresh_when :etag => @page, :last_modified => @page.updated_at.utc, :public => true

          if @page.cache_strategy != 'simple' # varnish
            response.cache_control[:max_age] = @page.cache_strategy
          end
        end

        render :text => output, :layout => false, :status => page_status unless performed?
      end

      def not_found_page
        current_site.pages.not_found.published.first
      end

      def editing_page?
        @editing
      end

      def page_status
        @page.not_found? ? :not_found : :ok
      end

    end

  end
end