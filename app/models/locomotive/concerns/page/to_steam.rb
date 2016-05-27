module Locomotive
  module Concerns
    module Page
      module ToSteam

        def to_steam
          @steam_page ||= steam_repositories.page.build(self.attributes.symbolize_keys)
        end

        private

        def steam_repositories
          @steam_repositories ||= Locomotive::Steam::Services.build_instance.repositories
        end

      end

    end
  end
end
