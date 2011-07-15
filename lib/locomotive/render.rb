module Locomotive
  module Render

    extend ActiveSupport::Concern

    module InstanceMethods

      protected

      def render_locomotive_page
        if request.fullpath =~ /^\/admin\//
          render :template => "/admin/errors/404", :layout => '/admin/layouts/box', :status => :not_found
        else
          @page = locomotive_page

          redirect_to(@page.redirect_url) and return if @page.present? && @page.redirect?

          render_no_page_error and return if @page.nil?

          output = @page.render(locomotive_context)

          self.prepare_and_set_response(output)
        end
      end

      def render_no_page_error
        render :template => "/admin/errors/no_page", :layout => false
      end

      def locomotive_page
        path = (params[:path] || request.fullpath).clone # TODO: params[:path] is more consistent
        path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '')
        path.gsub!(/^\//, '')
        path = 'index' if path.blank?

        page = nil
        parents = []
        @content_instances = ActiveSupport::OrderedHash.new

        path.split('/').each do |slug|
          paths = []
          paths << parents + [ slug ]
          paths << parents + [ "content_type_template" ] unless paths == [[ "index" ]]
          paths.map! { |p| p.join '/' }
          if page = current_site.pages.any_in(:fullpath => paths).sort_by { |p| p.templatized.to_s }.first
            parents << page.slug
            if page.templatized?
              @content_instance = page.content_type.contents.where(:_slug => slug).first
              @content_instances[page.content_type.slug.singularize] = @content_instance
              page = nil if @content_instance.nil? || (!@content_instance.visible? && current_admin.nil?) # content instance not found or not visible
            end
          end
          break unless page
        end
        page = nil if page and not page.published? and current_admin.nil?
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
          'url'               => request.url,
          'now'               => Time.now.utc,
          'today'             => Date.today
        }.merge(flash.stringify_keys) # data from api

        if @page.templatized? 
          assigns['content_instance'] = @content_instance
          assigns['content_instances'] = @content_instances.values
          @content_instances.each { |k,v| assigns[k] = v } # just here to help to write readable liquid code
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

        render :text => output, :layout => false, :status => page_status
      end

      def not_found_page
        current_site.pages.not_found.published.first
      end

      def editing_page?
        self.params[:editing] == true && current_admin
      end

      def page_status
        @page.not_found? ? :not_found : :ok
      end

    end

  end
end
