require 'fileutils'
require 'zip/zip'

# Just a simple helper class to export quickly an existing and live locomotive website.
# FIXME: will be replaced by the API in the next months
module Locomotive
  class Export

    @@instance = nil

    def initialize(site, filename = nil)
      @site           = site
      @filename       = filename || Time.now.to_i.to_s
      @target_folder  = File.join(Rails.root, 'tmp', 'export', @filename)
      @site_hash      = {} # used to generate the site.yml and compiled_site.yml files

      self.create_target_folder
    end

    def run!
      self.initialize_site_hash

      self.log('copying assets')
      self.copy_assets

      self.log('copying theme assets')
      self.copy_theme_assets

      self.log('copying pages')
      self.copy_pages

      self.log('copying snippets')
      self.copy_snippets

      self.log('copying content types')
      self.copy_content_types

      self.log('copying config files')
      self.copy_config_files

      self.log('generating the zip file')
      self.zip_it!
    end

    # returns the path to the zipfile
    def self.run!(site, filename = nil)
      @@instance = self.new(site, filename)
      @@instance.run!
    end

    protected

    def zip_it!
      "#{@target_folder}.zip".tap do |dst|
        FileUtils.rm(dst, :force => true)
        ::Zip::ZipFile.open(dst, ::Zip::ZipFile::CREATE) do |zipfile|
          Dir[File.join(@target_folder, '**/*')].each do |file|
            entry = file.gsub(@target_folder + '/', '')
            zipfile.add(entry, file)
          end
        end
      end
    end

    def create_target_folder
      FileUtils.rm_rf(@target_folder)
      FileUtils.mkdir_p(@target_folder)
      %w(app/content_types app/views/snippets app/views/pages config data public).each do |f|
        FileUtils.mkdir_p(File.join(@target_folder, f))
      end
    end

    def initialize_site_hash
      attributes = self.extract_attributes(@site, %w(name locale seo_title meta_description meta_keywords))

      attributes['pages'] = []
      attributes['content_types'] = {}

      @site_hash = { 'site' => attributes }
    end

    def copy_config_files
      File.open(File.join(self.config_folder, 'compiled_site.yml'), 'w') do |f|
        f.write(yaml(@site_hash))
      end

      @site_hash['site'].delete('content_types')

      File.open(File.join(self.config_folder, 'site.yml'), 'w') do |f|
        f.write(yaml(@site_hash))
      end
    end

    def copy_pages
      Page.quick_tree(@site, false).each { |p| self._copy_pages(p) }
    end

    def copy_snippets
      @site.snippets.each do |snippet|
        File.open(File.join(self.snippets_folder, "#{snippet.slug}.liquid"), 'w') do |f|
          f.write(snippet.template)
        end
      end
    end

    def copy_content_types
      @site.content_types.each do |content_type|
        attributes = self.extract_attributes(content_type, %w(name description slug order_by order_direction group_by_field_name api_enabled))

        attributes['highlighted_field_name'] = content_type.highlighted_field._alias

        # custom_fields
        fields = []
        content_type.content_custom_fields.each do |field|
          field_attributes = self.extract_attributes(field, %w(label kind hint required))

          if field.target.present?
            target_klass = field['target'].constantize

            field_attributes['target'] = target_klass._parent.slug

            if field['reverse_lookup'].present?
              field_attributes['reverse'] = target_klass.custom_field_name_to_alias(field['reverse_lookup'])
            end
          end

          fields << { field._alias => field_attributes }
        end

        attributes['fields'] = fields

        @site_hash['site']['content_types'][content_type.name] = attributes.clone

        # [structure] copy it into its own file
        File.open(File.join(self.content_types_folder, "#{content_type.slug}.yml"), 'w') do |f|
          f.write(self.yaml(attributes))
        end

        # data
        data = self.extract_contents(content_type)

        # [data] copy them into their own file
        File.open(File.join(self.content_data_folder, "#{content_type.slug}.yml"), 'w') do |f|
          f.write(self.yaml(data))
        end

        @site_hash['site']['content_types'][content_type.name]['contents'] = data
      end
    end

    def copy_theme_assets
      @site.theme_assets.each do |theme_asset|
        target_path = File.join(self.public_folder, theme_asset.local_path)

        self.copy_file_from_an_uploader(theme_asset.source, target_path) do |bytes|
          if theme_asset.stylesheet_or_javascript?
            base_url = theme_asset.source.url.gsub(theme_asset.local_path, '')
            bytes.gsub(base_url, '/')
          else
            bytes
          end
        end
      end
    end

    def copy_assets
      @site.assets.each do |asset|
        target_path = File.join(self.samples_folder, asset.source_filename)
        self.copy_file_from_an_uploader(asset.source, target_path)
      end
    end

    protected

    def _copy_pages(page)
      attributes = self.extract_attributes(page, %w{title seo_title meta_description meta_keywords redirect_url content_type published})

      attributes['listed'] = page.listed? # in some cases, page.listed can be nil

      unless page.raw_template.blank?
        attributes.delete('redirect_url')

        if page.templatized?
          attributes['content_type'] = page.content_type.slug
        end

        # add editable elements
        page.editable_elements.each do |element|
          next if element.disabled? || (element.from_parent && element.default_content == element.content)

          el_attributes = self.extract_attributes(element, %w{slug block hint})

          case element
          when EditableShortText, EditableLongText
            el_attributes['content'] = self.replace_asset_urls_in(element.content || '')
          when EditableFile
            unless element.source_filename.blank?
              filepath = File.join('/', 'samples', element.source_filename)
              self.copy_file_from_an_uploader(element.source, File.join(self.public_folder, filepath))
              el_attributes['content'] = filepath
            else
              el_attributes['content'] = '' # not sure if we run into this
            end
          end

          (attributes['editable_elements'] ||= []) << el_attributes
        end

        page_templatepath = File.join(self.pages_folder, "#{page.fullpath}.liquid")

        FileUtils.mkdir_p(File.dirname(page_templatepath))

        File.open(page_templatepath, 'w') do |f|
          f.write(self.replace_asset_urls_in(page.raw_template))
        end
      end

      @site_hash['site']['pages'] << { page.fullpath => attributes }

      page.children.each { |p| self._copy_pages(p) }
    end

    def extract_attributes(object, fields)
      attributes = object.attributes.select { |k, v| fields.include?(k) && !v.blank? }

      if RUBY_VERSION =~ /1\.9/
        attributes
      else
        attributes.inject({}) { |memo, pair| memo.merge(pair.first => pair.last) }
      end
    end

    def pages_folder
      File.join(@target_folder, 'app', 'views', 'pages')
    end

    def snippets_folder
      File.join(@target_folder, 'app', 'views', 'snippets')
    end

    def content_types_folder
      File.join(@target_folder, 'app', 'content_types')
    end

    def config_folder
      File.join(@target_folder, 'config')
    end

    def content_data_folder
      File.join(@target_folder, 'data')
    end

    def public_folder
      File.join(@target_folder, 'public')
    end

    def samples_folder
      File.join(@target_folder, 'public', 'samples')
    end

    def copy_file_from_an_uploader(uploader, target_path, &block)
      FileUtils.mkdir_p(File.dirname(target_path))
      File.open(target_path, 'w') do |f|
        bytes = uploader.read

        bytes ||= ''

        bytes = block.call(bytes) if block_given?

        bytes = bytes.force_encoding('UTF-8') if RUBY_VERSION =~ /1\.9/
        f.write(bytes)
      end
    end

    def extract_contents(content_type)
      data = []

      highlighted_field_name = content_type.highlighted_field_name

      content_type.contents.each do |content|
        hash = {}

        content.custom_fields.each do |field|
          next if field._name == highlighted_field_name

          value = (case field.kind
          when 'file'
            uploader = content.send(field._name)
            unless uploader.blank?
              filepath = File.join('/samples', content_type.slug, content.send("#{field._name}_filename"))
              self.copy_file_from_an_uploader(uploader, File.join(self.public_folder, filepath))
            else
              filepath = nil
            end
            filepath
          when 'text'
            self.replace_asset_urls_in(content.send(field._name.to_sym) || '')
          when 'has_one'
            content.send(field.safe_alias.to_sym).highlighted_field_value rescue nil # no bound object
          when 'has_many'
            unless field.reverse_has_many?
              content.send(field.safe_alias.to_sym).collect(&:highlighted_field_value)
            end
          else
            content.send(field.safe_alias.to_sym)
          end)

          hash[field._alias] = value unless value.blank?
        end

        data << { content.highlighted_field_value => hash }
      end

      data
    end

    def replace_asset_urls_in(text)
      base_url = AssetUploader.new(Asset.new(:site => @site)).store_dir
      (base_url = base_url.split('/')).pop
      base_url = base_url.join('/')

      text.gsub(%r(#{base_url}/[a-z0-9]{10,}/), "#{base_url.starts_with?('http') ? '/' : ''}samples/")
    end

    def yaml(hash_or_array)
      method = hash_or_array.respond_to?(:ya2yaml) ? :ya2yaml : :to_yaml
      string = (if hash_or_array.respond_to?(:keys)
        hash_or_array.dup.stringify_keys!
      else
        hash_or_array
      end).send(method)
      string.gsub('!ruby/symbol ', ':').sub('---', '').split("\n").map(&:rstrip).join("\n").strip
    end

    def log(message, domain = '')
      head = "[export_template][#{@site.name}]"
      head += "[#{domain}]" unless domain.blank?
      ::Locomotive.log "\t#{head} #{message}"
    end

  end

end