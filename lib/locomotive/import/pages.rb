module Locomotive
  module Import
    module Pages

      def self.process(context)
        site, pages, theme_path = context[:site], context[:database]['pages'], context[:theme_path]

        context[:done] = {} # initialize the hash storing pages already processed

        self.add_index_and_404(context)

        Dir[File.join(theme_path, 'templates', '**/*')].each do |template_path|

          fullpath = template_path.gsub(File.join(theme_path, 'templates'), '').gsub('.liquid', '').gsub(/^\//, '')

          # puts "=========== #{fullpath} ================="

          next if %w(index 404).include?(fullpath)

          self.add_page(fullpath, context)
        end
      end

      def self.add_page(fullpath, context)
        puts "....adding #{fullpath}"

        page = context[:done][fullpath]

        return page if page # already added, so skip it

        site, pages, theme_path = context[:site], context[:database]['site']['pages'], context[:theme_path]

        template = File.read(File.join(theme_path, 'templates', "#{fullpath}.liquid"))

        self.build_parent_template(template, context)

        parent = self.find_parent(fullpath, context)

        # puts "updating..... #{fullpath} / #{template}"

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

        # do not parse liquid templates now
        # page.instance_variable_set(:@template_changed, false)

        page.save!

        site.reload

        context[:done][fullpath] = page

        page
      end

      def self.build_parent_template(template, context)
        # puts "building parent_template #{template.blank?}"

        # just check if the template contains the extends keyword
        # template
        fullpath = template.scan(/\{% extends (\w+) %\}/).flatten.first

        if fullpath # inheritance detected
          fullpath.gsub!("'", '')

          # puts "found parent_template #{fullpath}"

          return if fullpath == 'parent'

          self.add_page(fullpath, context)
        else
          # puts "no parent_template found #{fullpath}"
        end
      end

      def self.find_parent(fullpath, context)
        # puts "finding parent for #{fullpath}"

        site = context[:site]

        segments = fullpath.split('/')

        return site.pages.index.first if segments.size == 1

        (segments.last == 'index' ? 2 : 1).times { segments.pop }

        parent_fullpath = File.join(segments.join('/'), 'index').gsub(/^\//, '')

        # look for a local index page in db
        parent = site.pages.where(:fullpath => parent_fullpath).first

        parent || self.add_page(parent_fullpath, context)
      end

      def self.add_index_and_404(context)
        site, pages, theme_path = context[:site], context[:database]['site']['pages'], context[:theme_path]

        %w(index 404).each do |slug|
          page = site.pages.where({ :slug => slug, :depth => 0 }).first

          # puts "building system page (#{slug}) => #{page.inspect}"

          page ||= sites.pages.build(:slug => slug, :parent => nil)

          template = File.read(File.join(theme_path, 'templates', "#{slug}.liquid"))

          page.attributes = { :raw_template => template }.merge(pages[slug] || {})

          page.save! rescue nil # TODO better error handling

          site.reload

          context[:done][slug] = page
        end
      end

    end
  end
end