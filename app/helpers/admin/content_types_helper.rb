module Admin::ContentTypesHelper

  MAX_DISPLAYED_CONTENTS = 4

  def fetch_content_types
    return @content_types if @content_types

    @content_types = current_site.content_types.ordered.
      limit(:contents => Locomotive.config.lastest_items_nb).
      only(:name, :slug, :highlighted_field_name, :content_custom_fields_version, :order_by, :serialized_item_template).to_a

    if @content_type && @content_type.persisted? && @content_types.index(@content_type) >= MAX_DISPLAYED_CONTENTS
      @content_types.delete(@content_type)
      @content_types.insert(0, @content_type)
    end

    # be sure, we've got the custom klass up-to-date, otherwise it will fail miserably
    @content_types.each do |content_type|
      if content_type.content_klass_out_of_date?
        content_type.reload
        content_type.invalidate_content_klass
      end
    end

    @content_types
  end

  def each_content_type_menu_item(which = :first, &block)
    types = fetch_content_types
    sliced = []

    if which == :first
      sliced = types[0..MAX_DISPLAYED_CONTENTS - 1]
    elsif types.size > MAX_DISPLAYED_CONTENTS
      sliced = types[MAX_DISPLAYED_CONTENTS, types.size - MAX_DISPLAYED_CONTENTS]
    end

    return [] if sliced.empty?

    sliced.each do |content_type|
      next if content_type.new_record?
      item_on = (content_type.slug == @content_type.slug) rescue nil

      label = truncate(content_type.name, :length => 15)
      url = admin_contents_url(content_type.slug)
      css = @content_type && content_type.slug == @content_type.slug ? 'on' : ''

      html = admin_submenu_item(label, url, :i18n => false, :css => css) do
        yield(content_type)
      end

      haml_concat(html)
    end
  end

  def other_content_types(&block)
    types = fetch_content_types

    if types.size > MAX_DISPLAYED_CONTENTS
      sliced = types[MAX_DISPLAYED_CONTENTS, types.size - MAX_DISPLAYED_CONTENTS]

      html = admin_submenu_item('...', '#', :i18n => false) do
        yield(sliced)
      end

      haml_concat(html)
    end
  end

  def content_label_for(content)
    if content._parent.raw_item_template.blank?
      content._label # default one
    else
      assigns = {
        'site'              => current_site,
        'content'           => content.to_liquid
      }

      registers = {
        :controller     => self,
        :site           => current_site,
        :current_admin  => current_admin
      }

      preserve(content._parent.item_template.render(::Liquid::Context.new({}, assigns, registers)))
    end
  end

end