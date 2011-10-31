class Locomotive::MainMenuCell < ::Locomotive::MenuCell

  protected

  def build_list
    add :contents, :url => pages_url
    add :settings, :url => edit_current_site_url
  end

end
