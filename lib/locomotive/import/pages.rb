module Locomotive
  module Import
    module Pages

      def self.process(context)
        site, pages, theme_path = context[:site], context[:database]['pages'], context[:theme_path]

        context[:done] = {} # initialize the hash storing pages already processed

        self.add_index_and_404(context)

        Dir[File.join(theme_path, 'templates', '**/*')].each do |template_path|

          fullpath = template_path.gsub(File.join(theme_path, 'templates'), '').gsub('.liquid', '').gsub(/^\//, '')

          next if %w(index 404).include?(fullpath)

          self.add_page(fullpath, context)
        end
      end

      def self.add_page(fullpath, context)
        puts "\t\t....adding #{fullpath}"

        page = context[:done][fullpath]

        return page if page # already added, so skip it

        site, pages, theme_path = context[:site], context[:database]['site']['pages'], context[:theme_path]

        template = File.read(File.join(theme_path, 'templates', "#{fullpath}.liquid")) rescue "Unable to find #{fullpath}.liquid"

        self.build_parent_template(template, context)

        parent = self.find_parent(fullpath, context)

        page = site.pages.where(:fullpath => fullpath).first || site.pages.build

        attributes = {
          :title        => fullpath.split('/').last.humanize,
          :slug         => fullpath.split('/').last,
          :parent       => parent,
          :raw_template => template
        }.merge(pages[fullpath] || {}).symbolize_keys

        # templatized ?
        if content_type_slug = attributes.delete(:content_type)
          attributes[:content_type] = site.content_types.where(:slug => content_type_slug).first
        end

        page.attributes = attributes

        page.save!

        site.reload

        context[:done][fullpath] = page

        page
      end

      def self.build_parent_template(template, context)
        # just check if the template contains the extends keyword
        fullpath = template.scan(/\{% extends (\w+) %\}/).flatten.first

        if fullpath # inheritance detected
          fullpath.gsub!("'", '')

          return if fullpath == 'parent'

          self.add_page(fullpath, context)
        end
      end

      def self.find_parent(fullpath, context)
        site = context[:site]

        segments = fullpath.split('/')

        return site.pages.index.first if segments.size == 1

        segments.pop

        parent_fullpath = segments.join('/').gsub(/^\//, '')

        # look for a local index page in db
        parent = site.pages.where(:fullpath => parent_fullpath).first

        parent || self.add_page(parent_fullpath, context)
      end

      def self.add_index_and_404(context)
        site, pages, theme_path = context[:site], context[:database]['site']['pages'], context[:theme_path]

        %w(index 404).each_with_index do |slug, position|
          page = site.pages.where({ :slug => slug, :depth => 0 }).first

          page ||= sites.pages.build(:slug => slug, :parent => nil)

          template = File.read(File.join(theme_path, 'templates', "#{slug}.liquid"))

          page.attributes = { :raw_template => template, :position => position }.merge(pages[slug] || {})

          page.save! rescue nil # TODO better error handling

          site.reload

          context[:done][slug] = page
        end
      end

    end
  end
end