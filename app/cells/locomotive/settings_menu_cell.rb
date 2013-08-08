module Locomotive
  class SettingsMenuCell < SubMenuCell

    protected

    def build_list
      add :site,          url: edit_current_site_path
      add :theme_assets,  url: theme_assets_path
      add :translations,  url: translations_path
      add :account,       url: edit_my_account_path
    end

  end
end