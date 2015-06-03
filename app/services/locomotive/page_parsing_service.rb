module Locomotive

  class PageParsingService < Struct.new(:site, :locale)

    def find_or_create_editable_elements(page)
      [].tap do |elements|
        ActiveSupport::Notifications.subscribe(/^steam\.parse\.editable\./) do |name, start, finish, id, payload|
          parsed_page, attributes = payload[:page], payload[:attributes]

          # Note: parsed_page is a Steam entity
          _page = attributes[:fixed] ? Locomotive::Page.find(parsed_page._id) : page

          elements << [_page, attributes]
        end

        parse(page)

        persist_editable_elements(elements)
      end
    end

    private

    def parse(page)
      entity = repository.build(page.attributes.dup)
      decorated_page = Locomotive::Steam::Decorators::TemplateDecorator.new(entity, self.locale)

      parser = services.liquid_parser
      parser.parse(decorated_page)
    end

    def persist_editable_elements(elements)
      modified_pages = [] # group modifications by page

      elements.each do |couple|
        _page, attributes = couple

        element   = add_or_modify_editable_element(_page, attributes)
        couple[1] = element

        modified_pages << _page
      end

      modified_pages.uniq.map(&:save!)
    end

    def add_or_modify_editable_element(page, attributes)
      if element = page.editable_elements.by_block_and_slug(attributes[:block], attributes[:slug]).first
        element.attributes = attributes
        element
      else
        klass = "Locomotive::#{attributes[:type].to_s.classify}".constantize
        element = page.editable_elements.build(attributes, klass)
      end
    end

    def services
      @services ||= Locomotive::Steam::Services.build_instance.tap do |services|
        services.set_site(self.site)
        services.locale = self.locale
      end
    end

    def repository
      services.repositories.page
    end

  end

end
