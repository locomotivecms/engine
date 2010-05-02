module Admin::PagesHelper
  
  def parent_pages_options
    roots = current_site.pages.roots.where(:slug.ne => '404').and(:_id.ne => @page.id)
    
    puts roots.to_a.inspect
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
  
end