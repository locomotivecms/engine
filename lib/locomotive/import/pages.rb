module Locomotive
  module Import
    class Pages < Base

      def process
        context[:done] = {} # initialize the hash storing pages already processed

        self.add_page('404')

        self.add_page('index')

        Dir[File.join(theme_path, 'app', 'views', 'pages', '**/*')].each do |template_path|

          fullpath = template_path.gsub(File.join(theme_path, 'app', 'views', 'pages'), '').gsub('.liquid', '').gsub(/^\//, '')

          next if %w(index 404).include?(fullpath)

          self.add_page(fullpath)
        end

        # make sure all the pages were processed (redirection pages without template for instance)
        self.pages.each { |fullpath, attributes| self.add_page_without_template(fullpath.to_s) }
      end

      protected

      def add_page_without_template(fullpath)
        page = context[:done][fullpath]

        return page if page # already added, so skip it

        self._save_page!(fullpath, nil)
      end

      def add_page(fullpath)
        page = context[:done][fullpath]

        return page if page # already added, so skip it

        template = File.read(File.join(theme_path, 'app', 'views', 'pages', "#{fullpath}.liquid")) rescue "Unable to find #{fullpath}.liquid"

        self.replace_images!(template)

        self.build_parent_template(template)

        self._save_page!(fullpath, template)
      end

      def _save_page!(fullpath, template)
        parent = self.find_parent(fullpath)

        attributes = {
          :title        => fullpath.split('/').last.humanize,
          :slug         => fullpath.split('/').last,
          :parent       => parent,
          :raw_template => template,
          :published    => true
        }.merge(self.pages[fullpath] || {}).symbolize_keys

        if %w(index 404).include?(fullpath)
          attributes[:position] = fullpath == 'index' ? 0 : 1
        end

        attributes[:position] = attributes[:position].to_i

        # templatized ?
        if content_type_slug = attributes.delete(:content_type)
          attributes.merge!({
            :templatized  => true,
            :content_type => site.content_types.where(:slug => content_type_slug).first
          })
        end

        # redirection page ?
        attributes[:redirect] = true if attributes[:redirect_url].present?

        # Don't want the editable elements to be imported: they will be regenerated
        editable_elements_attributes = attributes.delete(:editable_elements)

        page = site.pages.where(:fullpath => self.sanitize_fullpath(fullpath)).first || site.pages.build

        page.attributes = attributes

        page.save!

        unless editable_elements_attributes.nil?
          self.assign_editable_elements(page, editable_elements_attributes)
        end

        self.log "adding #{page.fullpath} (#{template.blank? ? 'without' : 'with'} template) / #{page.position}"

        site.reload

        context[:done][fullpath] = page

        page
      end

      def assign_editable_elements(page, elements)
        page.reload # editable elements are not synchronized otherwise

        elements.each do |attributes|
          element = page.find_editable_element(attributes['block'], attributes['slug'])

          next if element.nil?

          if element.respond_to?(:source)
            unless attributes['content'].blank?
              asset_path = File.join(theme_path, 'public', attributes['content'])

              if File.exists?(asset_path)
                element.source = File.open(asset_path)
              end
            end
          else
            element.content = attributes['content']
          end
        end

        page.save!
      end

      def build_parent_template(template)
        # just check if the template contains the extends keyword
        fullpath = template.scan(/\{% extends \'?([\w|\/]+)\'? %\}/).flatten.first

        if fullpath # inheritance detected
          return if fullpath == 'parent'
          self.add_page(fullpath)
        end
      end

      def find_parent(fullpath)
        return nil if %w(index 404).include?(fullpath) # avoid cyclic issue with the index page

        segments = fullpath.split('/')

        return site.pages.root.first if segments.size == 1

        segments.pop

        parent_fullpath = segments.join('/').gsub(/^\//, '')

        # look for a local index page in db
        parent = site.pages.where(:fullpath => parent_fullpath).first

        parent || self.add_page(parent_fullpath)
      end

      def replace_images!(template)
        return if template.blank?

        template.gsub!(/\/samples\/(.*\.[a-zA-Z0-9]{3})/) do |match|
          name = File.basename($1)

          if asset = site.assets.where(:source_filename => name).first
            asset.source.url
          else
            match
          end
        end
      end

      def pages
        @pages ||= self.retrieve_pages
      end

      def retrieve_pages
        pages = context[:database]['site']['pages']

        if pages.is_a?(Array) # ordered list of pages
          tmp, positions = {}, Hash.new(0)
          pages.each do |data|
            position = nil
            fullpath = data.keys.first.to_s

            unless %w(index 404).include?(fullpath)
              (segments = fullpath.split('/')).pop
              position_key = segments.empty? ? 'index' : segments.join('/')

              position = positions[position_key]

              positions[position_key] += 1
            end

            attributes = (data.values.first || {}).merge(:position => position)

            tmp[fullpath] = attributes
          end
          pages = tmp
        end

        pages
      end

      def sanitize_fullpath(fullpath)
        fullpath.gsub(/\/template$/, '/content_type_template')
      end

    end
  end
end