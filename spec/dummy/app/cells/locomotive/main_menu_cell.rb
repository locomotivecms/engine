module Locomotive
  class MainMenuCell < MenuCell

    update_for :foo do |new_menu|
      new_menu.add_before :settings, :foo, url: new_menu.main_app.foo_url, icon: 'icon-shopping-cart'
    end

  end
end