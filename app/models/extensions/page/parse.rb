module Models
  module Extensions
    module Page
      module Parse

        extend ActiveSupport::Concern

        included do
          field :serialized_template, :type => Binary
          field :template_dependencies, :type => Array, :default => []

          before_validation :serialize_template
          after_save :update_template_descendants

          validate :template_must_be_valid

          scope :pages, lambda { |domain| { :any_in => { :domains => [*domain] } } }
        end

        module InstanceMethods

          def template
            @template ||= Marshal.load(read_attribute(:serialized_template).to_s) rescue nil
          end

          protected

          def parse(context = {})
            @template = ::Liquid::Template.parse(self.raw_template, { :site => self.site, :page => self }.merge(context))
            @template.root.context.clear

            self.template_dependencies = parent_templates(@template.root)

            # TODO: snippets dependencies
          end

          def serialize_template
            if self.new_record? || self.raw_template_changed?
              @template_changed = true

              @parsing_errors = []
              begin
                self._serialize_template
              rescue ::Liquid::SyntaxError => error
                @parsing_errors << :liquid_syntax
              rescue ::Locomotive::Liquid::PageNotFound => error
                @parsing_errors << :liquid_extend
              end
            end
          end

          def _serialize_template(context = {})
            self.parse(context)
            self.serialized_template = BSON::Binary.new(Marshal.dump(@template))
          end

          def template_must_be_valid
            @parsing_errors.try(:each) { |msg| self.errors.add :template, msg }
          end

          def parent_templates(node, templates = [])
            templates << node.page_id if node.is_a?(Locomotive::Liquid::Tags::Extends)

            if node.respond_to?(:nodelist)
              node.nodelist.each do |child|
                self.parent_templates(child, templates)
              end
            end

            templates
          end

          def update_template_descendants
            return unless @template_changed == true

            # we admit at this point that the current template is up-to-date
            descendants = self.site.pages.any_in(:template_dependencies => [self.id]).to_a

            # group them by fullpath for better performance
            cached = descendants.inject({}) { |memo, page| memo[page.fullpath] = page; memo }

            self._update_direct_template_descendants(descendants, cached)

            # finally save them all
            descendants.map(&:save)

            # puts "** first descendant = #{descendants.first.object_id} / #{descendants.first.template.inspect}"
          end

          def _update_direct_template_descendants(descendants, cached)
            direct_descendants = descendants.select do |page|
              (page.template_dependencies - self.template_dependencies).size == 1
            end

            direct_descendants.each do |page|
              page.send(:_serialize_template, { :cached_parent => self, :cached_pages => cached })

              page.send(:_update_direct_template_descendants, descendants, cached)
            end
          end

        end

      end
    end
  end
end