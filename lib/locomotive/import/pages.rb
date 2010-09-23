module Locomotive
  module Import
    module Pages

      def self.process(context)
        site, pages, theme_path = context[:site], context[:database]['pages'], context[:theme_path]

        self.add_index_and_404(context)

        Dir[File.join(theme_path, 'templates', '**/*')].each do |template_path|

          fullpath = template_path.gsub(File.join(theme_path, 'templates'), '')

          puts "fullpath = #{fullpath}"

          next if %w(index 404).include?(fullpath)

          self.add_page(fullpath, context)
        end
      end

      def add_page(fullpath, context)
        site = context[:site]

        parent = self.find_parent(fullpath, context)

        puts "adding #{fullpath}"

        page = site.pages.where(:fullpath => fullpath).first || site.pages.build

        attributes = { :fullpath => fullpath, :parent => parent }.merge(context[:database]['pages'][fullpath] || {})
        attributes.symbolize_keys!

        # templatized ?
        if content_type_slug = attributes.delete(:content_type)
          attributes[:content_type] = site.content_types.where(:slug => content_type_slug).first
        end

        page.attributes = attributes

        # do not parse liquid templates now
        page.instance_variable_set(:@template_changed, false)

        page.save!

        site.reload
      end

      def find_parent(fullpath, context)
        segments = fullpath.split('/')

        return site.pages.index.first if segments.empty?

        (segments.last == 'index' ? 2 : 1).times { segments.pop }

        parent_fullpath = File.join(segments.join('/'), 'index')

        # look for a local index page in db
        parent = site.pages.where(:fullpath => parent_fullpath).first

        parent || self.add_page(parent_fullpath, context)
      end

      def add_index_and_404(context)
        site, database = context[:site], context[:database]

        %w(index 404).each do |slug|
          page = site.pages.where({ :slug => slug, :depth => 0 }).first

          page ||= sites.pages.build(:slug => slug, :parent => nil)

          page.attributes = database['pages'][slug]

          page.save!

          site.reload
        end
      end

    end
  end
end