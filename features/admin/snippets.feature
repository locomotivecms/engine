Feature: Snippets
  In order to manage snippets
  As an administrator
  I want to add/edit/delete snippets of my site

Background:
  Given I have the site: "test site" set up
  And I am an authenticated user
  And a snippet named "yield" with the template:
    """
    HELLO WORLD !
    """

Scenario: Updating a Snippet that includes another snippet
  And a page named "snippet-test" with the template:
    """
    {% include 'yield' %}
    """
  When I go to theme assets
  And I follow "yield"
  And I fill in "snippet_template" with "{% include 'other' %}"
  And I press "Update"
  Then I should see "Snippet was successfully updated."
  And I should have "{% include 'other' %}" in the yield snippet
  Then show me the page
