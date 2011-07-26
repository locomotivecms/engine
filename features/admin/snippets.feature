Feature: Snippets
  In order to manage snippets
  As an administrator
  I want to add/edit/delete snippets of my site

Background:
  Given I have the site: "test site" set up
  And I am an authenticated user
  And a page named "home" with the template:
  """
  {% include 'yield' %}
  """
  And a snippet named "yield" with the template:
  """
  "yield"
  """


Scenario: Creating a Snippet
  When I go to theme assets
  And I follow "new snippet"
  And I fill in "Name" with "Banner"
  And I fill in "Slug" with "banner"
  And I fill in "snippet_template" with "banner"
  And I press "Create"
  Then I should see "Snippet was successfully created."
  And I should have "banner" in the banner snippet

Scenario: Updating a Snippet that includes another snippet
  Given a snippet named "other" with the template:
  """
  "other"
  """
  When I go to theme assets
  And I follow "yield"
  And I fill in "snippet_template" with "{% include 'other' %}"
  And I press "Save"
  Then I should see "Snippet was successfully updated."
  And I should have "{% include 'other' %}" in the yield snippet
