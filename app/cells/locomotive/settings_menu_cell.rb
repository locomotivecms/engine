class Locomotive::SettingsMenuCell < ::Locomotive::SubMenuCell

  protected

  def build_list
    add :site, :url => edit_locomotive_current_site_url
    add :theme_assets, :url => locomotive_theme_assets_url
    add :account, :url => edit_locomotive_my_account_url
  end

end
