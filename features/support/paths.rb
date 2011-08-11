module NavigationHelpers
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
      new_admin_session_path
    when /logout/
      destroy_admin_session_path
    when /pages( list)?/
      admin_pages_path
    when /new page/
      new_admin_page_path
    when /"(.*)" edition page/
      page = Site.first.pages.where(:slug => $1).first
      edit_admin_page_path(page)
    when /theme assets/
      admin_theme_assets_path
    when /site settings/
      edit_admin_current_site_path
    when /account settings/
      edit_admin_my_account_path
    when /import page/
      new_admin_import_path
    when /export page/
      new_admin_export_path
    when /the "(.*)" model list page/
      content_type = Site.first.content_types.where(:name => $1).first
      admin_contents_path(content_type.slug)
    when /the "(.*)" model creation page/
      content_type = Site.first.content_types.where(:name => $1).first
      new_admin_content_path(content_type.slug)
    when /the "(.*)" model edition page/
      content_type = Site.first.content_types.where(:name => $1).first
      edit_admin_content_type_path(content_type)

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


# module NavigationHelpers
#   # Maps a name to a path. Used by the
#   #
#   #   When /^I go to (.+)$/ do |page_name|
#   #
#   # step definition in web_steps.rb
#   #
#   def path_to(page_name)
#     case page_name
#
#     when /the home\s?page/
#       '/'
#     when /login/
#       new_admin_session_path
#     when /logout/
#       destroy_admin_session_path
#     when /pages( list)?/
#       admin_pages_path
#     when /new page/
#       new_admin_page_path
#     when /"(.*)" edition page/
#       page = Site.first.pages.where(:slug => $1).first
#       edit_admin_page_path(page)
#     when /theme assets/
#       admin_theme_assets_path
#     when /site settings/
#       edit_admin_current_site_path
#     when /import page/
#       new_admin_import_path
#     when /the "(.*)" model edition page/
#       content_type = Site.first.content_types.where(:name => $1).first
#       edit_admin_content_type_path(content_type)
#
#     # Add more mappings here.
#     # Here is an example that pulls values out of the Regexp:
#     #
#     #   when /^(.*)'s profile page$/i
#     #     user_profile_path(User.find_by_login($1))
#
#     else
#       begin
#         page_name =~ /the (.*) page/
#         path_components = $1.split(/\s+/)
#         self.send(path_components.push('path').join('_').to_sym)
#       rescue Object => e
#         raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
#           "Now, go and add a mapping in #{__FILE__}"
#       end
#     end
#   end
# end
#
# World(NavigationHelpers)
