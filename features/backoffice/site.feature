Feature: Manage my site
  In order to manage my site
  As an administrator
  I want to edit/delete my site

Background:
  Given I have the site: "test site" set up

Scenario: Site settings are not accessible for non authenticated accounts
  Given I am not authenticated
  When I go to the site settings
  Then I should see "You need to sign in or sign up before continuing"

Scenario: Add a new site
  Given I am an authenticated user
  When I go to the account settings
  And I follow "new site"
  Then I should see "Fill in the form below to create your new site."
  When I fill in "Name" with "Acme"
  And I fill in "Subdomain" with "acme"
  And I press "Create"
  Then I should see "Site was successfully created." in the html code
  And I should be a administrator of the "Acme" site

Scenario: Add a new site with chosen locale
  Given I am an authenticated user
  When I go to the account settings
  And I follow "new site"
  When I fill in "Name" with "Acme"
  And I fill in "Subdomain" with "acme"
  And I select "Russian" from "First language"
  When I press "Create"
  Then I should see "Site was successfully created." in the html code

Scenario: Change timezone of site
  Given I am an authenticated user
  When I go to the site settings
  And I select "(GMT+04:00) Moscow" from "Timezone"
  Then I press "Save"
  Then I should see "My site was successfully updated." in the html code

@javascript
Scenario: Adding a domain to a site
  Given I am an authenticated user
  Then I should be able to add a domain to my site

@javascript
Scenario: Removing a domain from a site
  Given I am an authenticated user
  Then I should be able to remove a domain from my site

@javascript
Scenario: Removing a membership
  Given I am an authenticated user
  Then I should be able to remove a membership from my site

@javascript
Scenario: Saving a site with AJAX
  Given I am an authenticated user
  Then I should be able to save the site with AJAX
  Given multi_sites is disabled
  Then I should be able to save the site with AJAX

@javascript
Scenario: Multiple saves
  Given I am an authenticated user
  When I go to the site settings
  And I press "Save"
  Then I should see "My site was successfully updated."
  When I press "Save"
  Then I should see "My site was successfully updated."
