module Locomotive
  class MainMenuCell < MenuCell

    protected

    def build_list
      add :contents,  :url => pages_url,							:icon => 'icon-folder-open'
      add :settings,  :url => edit_current_site_url,	:icon => 'icon-cog'
    end

  end
end