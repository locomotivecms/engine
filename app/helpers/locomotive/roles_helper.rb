module Locomotive
  module RolesHelper
    
    def options_for_role_models
      [].tap do |options|
        Locomotive::ContentTypeService.new(current_site).list.each do |model|
          options << [model.slug.titleize,model.slug]
        end
      end
    end

    def options_for_role_pages(role, pages)
      collection = []
      pages.each do |page|
        children_page = page.children
        collection << { id: page.id.to_s, text: page.title, checked: (role.role_pages.to_a.include? page.id.to_s) , hasChildren: children_page.present? , children: options_for_role_pages(role, children_page) }
      end
      collection
    end

  end
end