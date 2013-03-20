Feature: Manage Theme Assets
  In order to manage theme assets
  As an administrator
  I want to add/edit/delete theme assets of my site

Background:
  Given I have the site: "test site" set up
  And I am an authenticated user

Scenario: Theme assets list is not accessible for non authenticated accounts
  Given I am not authenticated
  When I go to theme assets
  Then I should see "Log in"

Scenario: Uploading a valid image
  When I go to theme assets
  And I follow "new file"
  And I attach the file "spec/fixtures/assets/5k.png" to "File"
  And I press "Create"
  Then I should see "File was successfully created." in the html code
  And I should not see "Code"
  And I should see "images/5k.png"

Scenario: Uploading a stylesheet
  When I go to theme assets
  And I follow "new file"
  And I attach the file "spec/fixtures/assets/main.css" to "File"
  And I press "Create"
  Then I should see "File was successfully created." in the html code
  And I should see "Code"
  And I should see "stylesheets/main.css"

@javascript
Scenario: Updating a stylesheet
  Given a stylesheet asset named "application"
  When I go to theme assets
  And I follow "application.css" within the main content
  And I change the theme asset code to "Lorem ipsum (updated)"
  And I press "Save"
  Then I should see "File was successfully updated."
  And I should see "Editing application.css"
  And I should see "application.css"
  And I should see "Lorem ipsum (updated)" as the theme asset code

Scenario: Uploading a javascript
  When I go to theme assets
  And I follow "new file"
  And I fill in "Folder" with "javascripts/test"
  And I attach the file "spec/fixtures/assets/application.js" to "File"
  And I press "Create"
  Then I should see "File was successfully created." in the html code
  And I should see "Code"
  And I should see "javascripts/test/application.js"

@javascript
Scenario: Updating a javascript
  Given a javascript asset named "application"
  When I go to theme assets
  And I follow "application.js"
  And I change the theme asset code to "Lorem ipsum (updated)"
  And I press "Save"
  Then I should see "File was successfully updated."

Scenario: Uploading an image which already exists
  When I go to theme assets
  And I follow "new file"
  And I attach the file "spec/fixtures/assets/5k.png" to "File"
  And I press "Create"
  And I follow "new file"
  And I attach the file "spec/fixtures/assets/5k.png" to "File"
  And I press "Create"
  Then I should see "File was not created." in the html code
