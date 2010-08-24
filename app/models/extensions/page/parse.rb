module Models
  module Extensions
    module Page
      module Parse

        extend ActiveSupport::Concern

        included do
          field :serialized_template, :type => Binary
          field :template_dependencies, :type => Array, :default => []
          field :snippet_dependencies, :type => Array, :default => []

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

          def serialize_template
            if self.new_record? || self.raw_template_changed?
              @template_changed = true

              @parsing_errors = []

              begin
                self._parse_and_serialize_template
              rescue ::Liquid::SyntaxError => error
                @parsing_errors << :liquid_syntax
              rescue ::Locomotive::Liquid::PageNotFound => error
                @parsing_errors << :liquid_extend
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

            @template = ::Liquid::Template.parse(self.raw_template, default_context.merge(context))
            self.template_dependencies = context[:templates]
            self.snippet_dependencies = context[:snippets]

            @template.root.context.clear
            #
            # dependencies = all_dependencies(@template.root, { :templates => [], :snippets => [] })
            #
            # self.template_dependencies = dependencies[:templates]
            # self.snippet_dependencies = dependencies[:snippets]
          end

          def template_must_be_valid
            @parsing_errors.try(:each) { |msg| self.errors.add :template, msg }
          end

          # def all_dependencies(node, dependencies = {})
          #   case node
          #   when Locomotive::Liquid::Tags::Extends
          #     dependencies[:templates] << node.page_id
          #   when Locomotive::Liquid::Tags::Snippet
          #     dependencies[:snippets] << node.slug
          #   end
          #
          #   if node.respond_to?(:nodelist) && node.nodelist
          #     node.nodelist.each do |child|
          #       self.all_dependencies(child, dependencies)
          #     end
          #   end
          #
          #   dependencies
          # end

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
              page.send(:_parse_and_serialize_template, { :cached_parent => self, :cached_pages => cached })

              page.send(:_update_direct_template_descendants, descendants, cached)
            end
          end

        end

      end
    end
  end
end