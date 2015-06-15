require 'active_support/benchmarkable'

module Locomotive

  class PageParsingService < Struct.new(:site, :locale)

    include ActiveSupport::Benchmarkable

    def find_or_create_editable_elements(page)
      benchmark "Parse page #{page._id} find_or_create_editable_elements" do
        parsed = { extends: {}, blocks: {}, elements: [] }

        subscribe(parsed)

        parse(page)

        persist_editable_elements(page, parsed)
      end
    end

    private

    def subscribe(parsed)
      subscribe_to_extends(parsed[:extends])
      subscribe_to_blocks(parsed[:blocks])
      subscribe_to_editable_elements(parsed[:elements])
    end

    def subscribe_to_extends(extends)
      ActiveSupport::Notifications.subscribe('steam.parse.extends') do |name, start, finish, id, payload|
        parent_id, page_id = payload[:parent]._id, payload[:page]._id
        extends[parent_id] = page_id
      end
    end

    def subscribe_to_blocks(blocks)
      ActiveSupport::Notifications.subscribe('steam.parse.inherited_block') do |name, start, finish, id, payload|
        page_id, block_name, found_super = payload[:page]._id, payload[:name], payload[:found_super]
        blocks[page_id] ||= {}
        blocks[page_id][block_name] = found_super
      end
    end

    def subscribe_to_editable_elements(elements)
      ActiveSupport::Notifications.subscribe(/\Asteam\.parse\.editable\./) do |name, start, finish, id, payload|
        page, attributes = payload[:page], payload[:attributes]
        elements << [page, attributes]
      end
    end

    def parse(page)
      entity = repository.build(page.attributes.dup)
      decorated_page = Locomotive::Steam::Decorators::TemplateDecorator.new(entity, self.locale)

      parser = services.liquid_parser
      parser.parse(decorated_page)
    end

    def persist_editable_elements(page, parsed)
      modified_pages = [] # group modifications by page

      elements = parsed[:elements].map do |couple|
        _page, attributes = couple

        next if !persist_editable_element?(page, parsed, _page, attributes)

        # Note: _page is a Steam entity but we need a Mongoid document to save the elements
        _page = attributes[:fixed] ? Locomotive::Page.find(_page._id) : page

        element   = add_or_modify_editable_element(_page, attributes)
        couple[1] = element # we get now a Mongoid document instead of a Steam entity

        modified_pages << _page

        couple
      end.compact

      modified_pages.uniq.map(&:save!)

      elements
    end

    def persist_editable_element?(page, parsed, _page, attributes)
      page_id, block_name = _page._id, attributes[:block]
      descendant  = parsed[:extends][page_id]
      found_super = parsed[:blocks][descendant].try(:[], block_name)

      page._id == _page._id ||  # same page
      block_name.blank?     ||  # an editable_element out of a block (impossible to remove it in pages extending this template)
      found_super.nil?      ||  # block does not get overriden
      found_super               # if block.super is present in the descendant page
    end

    def add_or_modify_editable_element(page, attributes)
      puts attributes.inspect
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

    def logger
      Rails.logger
    end

  end

end
