class Admin::SettingsMenuCell < ::Admin::SubMenuCell #::Admin::MenuCell

  protected

  def build_list
    add :site, :url => edit_admin_current_site_url
    add :theme_assets, :url => admin_theme_assets_url
    add :account, :url => edit_admin_my_account_url
  end

  # def build_item(name, attributes)
  #   item = super
  #   enhanced_class = "#{'on' if name.to_s == sections(:sub)} #{item[:class]}"
  #   item.merge(:class => enhanced_class)
  # end

end
