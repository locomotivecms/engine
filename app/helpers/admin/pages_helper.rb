module Admin::PagesHelper

  def parent_pages_options
    roots = current_site.pages.roots.where(:slug.ne => '404').and(:_id.ne => @page.id)

    [].tap do |list|
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

  def options_for_page_cache_strategy
    [
      [t('.cache_strategy.none'), 'none'],
      [t('.cache_strategy.simple'), 'simple'],
      [t('.cache_strategy.hour'), 1.hour.to_s],
      [t('.cache_strategy.day'), 1.day.to_s],
      [t('.cache_strategy.week'), 1.week.to_s],
      [t('.cache_strategy.month'), 1.month.to_s]
    ]
  end

end
