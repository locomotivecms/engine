module Locomotive
  module Extensions
    module Page
      module Parse

        extend ActiveSupport::Concern

        included do
          ## fields ##
          field :serialized_template,   :type => Binary, :localize => true
          field :template_dependencies, :type => Array, :default => [], :localize => true
          field :snippet_dependencies,  :type => Array, :default => [], :localize => true

          ## virtual attributes
          attr_reader :template_changed

          ## callbacks ##
          before_validation :serialize_template
          after_save        :update_template_descendants

          ## validations ##
          validate :template_must_be_valid

          ## scopes ##
          scope :pages, lambda { |domain| { :any_in => { :domains => [*domain] } } }
        end

        def template
          @template ||= Marshal.load(self.serialized_template.to_s) rescue nil
        end

        protected

        def serialize_template
          if self.new_record? || self.raw_template_changed?
            @template_changed = true

            @parsing_errors = []

            begin
              self._parse_and_serialize_template
            rescue ::Liquid::SyntaxError => error
              @parsing_errors << I18n.t(:liquid_syntax, :fullpath => self.fullpath, :error => error.to_s, :scope => [:errors, :messages, :page])
            rescue ::Locomotive::Liquid::PageNotFound => error
              @parsing_errors << I18n.t(:liquid_extend, :fullpath => self.fullpath, :scope => [:errors, :messages, :page])
            rescue ::Locomotive::Liquid::PageNotTranslated => error
              @parsing_errors << I18n.t(:liquid_translation, :fullpath => self.fullpath, :scope => [:errors, :messages, :page])
            end
          end
        end

        def _parse_and_serialize_template(context = {})
          self.parse(context)
          self._serialize_template
        end

        def _serialize_template
          self.serialized_template = BSON::Binary.new(Marshal.dump(@template))
        end

        def parse(context = {})
          self.disable_all_editable_elements

          default_context = { :site => self.site, :page => self, :templates => [], :snippets => [] }

          context = default_context.merge(context)

          @template = ::Liquid::Template.parse(self.raw_template, context)

          self.template_dependencies  = context[:templates]
          self.snippet_dependencies   = context[:snippets]

          @template.root.context.clear
        end

        def template_must_be_valid
          @parsing_errors.try(:each) do |msg|
            self.errors.add :template, msg
            self.errors.add :raw_template, msg
          end
        end

        def update_template_descendants
          return unless @template_changed == true

          # we admit at this point that the current template is up-to-date
          template_descendants = self.site.pages.any_in("template_dependencies.#{::Mongoid::Fields::I18n.locale}" => [self.id]).to_a

          # group them by fullpath for better performance
          cached = template_descendants.inject({}) { |memo, page| memo[page.fullpath] = page; memo }

          self._update_direct_template_descendants(template_descendants.clone, cached)

          # finally save them all
          ::Locomotive::Page.without_callback(:save, :after, :update_template_descendants) do
            template_descendants.each do |page|
              page.save(:validate => false)
            end
          end
        end

        def _update_direct_template_descendants(template_descendants, cached)
          direct_descendants = template_descendants.select do |page|
            ((self.template_dependencies || []) + [self._id]) == (page.template_dependencies || [])
          end

          direct_descendants.each do |page|
            page.send(:_parse_and_serialize_template, { :cached_parent => self, :cached_pages => cached })

            template_descendants.delete(page) # no need to loop over it next time

            page.send(:_update_direct_template_descendants, template_descendants, cached) # move down
          end
        end

      end
    end
  end
end