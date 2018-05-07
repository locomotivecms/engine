module Locomotive
  class SectionService < struct.new(:site, :account)

    def self.load_definition_json(section)
      Locomotive::Steam::SectionFinderService.new(find section
    end
  end
end
