module NavigationHelpers
  include Locomotive::Engine.routes.url_helpers # Load engine routes

  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page$/
      '/'
    when /login/
      new_locomotive_account_session_path
    when /logout/
      destroy_locomotive_account_session_url
    when /pages( list)?/
      pages_path
    when /new page/
      new_page_path
    when /"(.*)" edition page/
      page = Locomotive::Site.first.pages.where(:slug => $1).first
      edit_page_path(page)
    when /theme assets/
      theme_assets_path
    when /translations/
      translations_path
    when /site settings/
      edit_current_site_path
    when /account settings/
      edit_my_account_path
    when /the list of "(.*)"/
      content_type = Locomotive::Site.first.content_types.where(:name => $1).first
      content_entries_path(content_type.slug)
    when /the "(.*)" model edition page/
      content_type = Locomotive::Site.first.content_types.where(:name => $1).first
      edit_content_type_path(content_type)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
