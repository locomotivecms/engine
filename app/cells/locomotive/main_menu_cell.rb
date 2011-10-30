class Locomotive::MainMenuCell < ::Locomotive::MenuCell

  protected

  def build_list
    add :contents, :url => locomotive_pages_url
    add :settings, :url => edit_locomotive_current_site_url
  end

end
