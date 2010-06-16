module Admin::PagesHelper
  
  def parent_pages_options
    roots = current_site.pages.roots.where(:slug.ne => '404').and(:_id.ne => @page.id)
    
    returning [] do |list|
      roots.each do |page|
        list = add_children_to_options(page, list)
      end
    end
  end
  
  def add_children_to_options(page, list)
    return list if page.path.include?(@page.id) || page == @page
    
    offset = '- ' * (page.depth || 0) * 2
        
    list << ["#{offset}#{page.title}", page.id]
    page.children.each { |child| add_children_to_options(child, list) }
    list
  end
  
  def options_for_page_cache_expiration
    [
      [t('.expiration.never'), 0],
      [t('.expiration.hour'), 1.hour],
      [t('.expiration.day'), 1.day],
      [t('.expiration.week'), 1.week],
      [t('.expiration.month'), 1.month]
    ]
  end
  
end