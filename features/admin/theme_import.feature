Feature: Import an Existing Theme
  In order to easily deploy a theme
  As an administrator
  I want to import a theme that was packaged with 'locomotive zip'

Background:
  Given I have the site: "test site" set up
  And I am an authenticated user
  
Scenario: Uploading the default theme
  When I go to site settings
  And I follow "import"
  And I attach the file "spec/fixtures/themes/default.zip" to "File"
  And I press "Send"
  Then I should see "Your site was successfully updated."
  
Scenario: Uploading the locomotive editor's empty theme
  When I go to site settings
  And I follow "import"
  And I attach the file "spec/fixtures/themes/default-from-editor.zip" to "File"
  And I press "Send"
  Then I should see "Your site was successfully updated."
  
Scenario: Uploading the locomotive editor's empty theme while copying samples
  When I go to site settings
  And I follow "import"
  And I attach the file "spec/fixtures/themes/default-from-editor.zip" to "File"
  And I check "Copy samples"
  And I press "Send"
  Then I should see "Your site was successfully updated."

Scenario: Uploading the locomotive editor's empty theme while resetting site
  When I go to site settings
  And I follow "import"
  And I attach the file "spec/fixtures/themes/default-from-editor.zip" to "File"
  And I check "Reset site"
  And I press "Send"
  Then I should see "Your site was successfully updated."

Scenario: Uploading the locomotive editor's empty theme while copying samples and resetting site
  When I go to site settings
  And I follow "import"
  And I attach the file "spec/fixtures/themes/default-from-editor.zip" to "File"
  And I check "Copy samples"
  And I check "Reset site"
  And I press "Send"
  Then I should see "Your site was successfully updated."

Scenario: Uploading a theme that uses a layouts folder
  When I go to site settings
  And I follow "import"
  And I attach the file "spec/fixtures/themes/layouts-folder.zip" to "File"
  And I press "Send"
  Then I should see "Your site was successfully updated."
  
  
  
