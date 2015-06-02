module Locomotive

  class PageParsingService < Struct.new(:site, :locale)

    def find_or_create_editable_elements(page)
      [].tap do |elements|
        ActiveSupport::Notifications.subscribe(/^steam\.parse\.editable\./) do |name, start, finish, id, payload|
          current_page, attributes = payload[:page], payload[:attributes]

          _page = attributes[:fixed] ? current_page : page

          elements << [_page, attributes]
        end

        parse(page)

        persist_editable_elements(elements)
      end
    end

    private

    # def persist_editable_elements(page, elements)
    def persist_editable_elements(elements)
      elements.each do |couple|
        _page, attributes = couple

        # next unless can_persist_element?(page, current_page, attributes)

        # update the element or or add the element to that page
        if element = _page.editable_elements.by_block_and_slug(attributes[:block], attributes[:slug]).first
          element.attributes = attributes
        else
          klass = "Locomotive::#{attributes[:type].to_s.classify}".constantize
          element = _page.editable_elements.build(attributes, klass)
        end

        couple[1] = element

        _page.save!

        # binding.pry
      end

      # page.save!
    end

    # Fixed editable elements are not added to the parsed page unless
    # they are defined in that page.
    #
    # @param [ Object ] page The page we are parsing
    # @param [ Object ] current_page The page where the editable element were found
    # @param [ Object ] attributes The attributes of the editable element
    #
    def can_persist_element?(page, current_page, attributes)
      !attributes[:fixed] || (attributes[:fixed] && page._id == current_page._id)
    end

    def parse(page)
      entity = repository.build(page.attributes.dup)
      decorated_page = Locomotive::Steam::Decorators::TemplateDecorator.new(entity, self.locale)

      parser = services.liquid_parser
      parser.parse(decorated_page)
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
