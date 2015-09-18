module Locomotive
  module Concerns
    module ThemeAsset
      module PlainText

        extend ActiveSupport::Concern

        included do

          ## validations ##
          validates_presence_of :plain_text_name, if: Proc.new { |a| a.performing_plain_text? }

          ## callbacks ##
          before_validation :store_plain_text

          ## accessors ##
          attr_accessor   :plain_text_name, :plain_text, :plain_text_type, :performing_plain_text

        end

        def plain_text_name
          if not @plain_text_name_changed
            @plain_text_name ||= self.safe_source_filename
          end
          @plain_text_name.gsub(/(\.[a-z0-9A-Z]+)$/, '') rescue nil
        end

        def plain_text_name=(name)
          @plain_text_name_changed = true
          @plain_text_name = name
        end

        def plain_text
          # only for ruby >= 1.9.x. Forget about ruby 1.8
          @plain_text ||= (self.source.read.force_encoding('UTF-8') rescue nil)
        end

        def plain_text_type
          @plain_text_type || (stylesheet_or_javascript? ? self.content_type : nil)
        end

        def performing_plain_text?
          Boolean.set(self.performing_plain_text) || false
        end

        def store_plain_text
          return if self.persisted? && !self.stylesheet_or_javascript?

          self.content_type ||= @plain_text_type if self.performing_plain_text?

          data = self.performing_plain_text? ? self.plain_text : self.source.read

          return if !self.stylesheet_or_javascript? || self.plain_text_name.blank? || data.blank?

          sanitized_source = self.escape_shortcut_urls(data)

          self.source = ::CarrierWave::SanitizedFile.new({
            tempfile: StringIO.new(sanitized_source),
            filename: "#{self.plain_text_name}.#{self.stylesheet? ? 'css' : 'js'}"
          })

          @plain_text = sanitized_source # no need to reset the plain_text instance variable to have the last version
        end

        def escape_shortcut_urls(text)
          return if text.blank?

          text.gsub(/[("'](\/(stylesheets|javascripts|images|media|fonts|pdfs|others)\/(([^;.]+)\/)*([a-zA-Z_\-0-9]+)\.[a-z]{2,4})(\?[0-9]+)?[)"']/) do |path|

            sanitized_path = path.gsub(/[("')]/, '').gsub(/^\//, '').gsub(/\?[0-9]+$/, '')

            if asset = self.site.theme_assets.where(local_path: sanitized_path).first
              timestamp = self.updated_at.to_i
              "#{path.first}#{asset.source.url}?#{timestamp}#{path.last}"
            else
              path
            end
          end
        end

      end
    end
  end
end

