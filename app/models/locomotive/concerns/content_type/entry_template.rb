module Locomotive
  module Concerns
    module ContentType
      module EntryTemplate

        extend ActiveSupport::Concern

        included do
          ## fields ##
          field :entry_template

          ## validation ##
          validate :entry_template_must_be_valid
        end

        def render_entry_template(context)
          return nil if entry_template.blank?
          parsed_entry_template.render(context)
        end

        def to_steam
          @steam_content_type ||= steam_repositories.content_type.build(self.attributes.symbolize_keys)
        end

        def to_steam_entry(entry)
          entry_attributes = entry.attributes.symbolize_keys

          steam_repositories.content_entry.with(to_steam).build(entry_attributes).tap do |entity|
            # copy error messages
            entry.errors.each do |name, message|
              next if name == :_slug
              entity.errors.add(name, message)
            end
          end
        end

        def steam_repositories
          @steam_repositories ||= Locomotive::Steam::Services.build_instance.repositories
        end

        protected

        def parsed_entry_template
          @parsed_entry_template ||= ::Liquid::Template.parse(self.entry_template)
        end

        def entry_template_must_be_valid
          begin
            parsed_entry_template
          rescue ::Liquid::SyntaxError => error
            self.errors.add :entry_template, error.to_s
          end
        end

      end
    end
  end
end
