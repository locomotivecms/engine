module Locomotive
  class SettingsMenuCell < SubMenuCell

    protected

    def build_list
      add :site,          :url => edit_current_site_url
      add :theme_assets,  :url => theme_assets_url
      add :translations,  :url => translations_url
      add :account,       :url => edit_my_account_url
    end

  end
end