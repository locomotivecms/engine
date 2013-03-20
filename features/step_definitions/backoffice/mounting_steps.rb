Given /^the engine is mounted on a non standard path$/ do
  Rails.application.routes.draw do
    mount Locomotive::Engine => '/my-custom-path', as: 'locomotive'
    match '/foo' => 'foo#index', as: 'foo'
  end
end

Then /^I should be able to access the backend$/ do
  # Ensure we can access the backend
  visit '/my-custom-path'
  page.should have_content 'LocomotiveCMS'

  # Ensure we can update the homepage content
  within('#pages-list') do
    click_link 'Home page'
  end
  click_button 'Save'
  page.should have_content 'Page was successfully updated'

  # Reset the routes back to normal once we are done
  Rails.application.reload_routes!
end
