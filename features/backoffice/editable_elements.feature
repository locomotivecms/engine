Feature: Manage Pages
  In order to manage pages
  As an administrator
  I want to add/edit/delete editable elements of my pages

Background:
  Given I have the site: "test site" set up
  And I am an authenticated user

@javascript
Scenario: Insert a control element
  Given a page named "hello-world" with the template:
    """
    {% block menu %}{% editable_control 'Menu position', options: 'top=Top of the Page,bottom=Bottom of the Page' %}bottom{% endeditable_control %}{% endblock %}
    """
  When I go to the "hello-world" edition page
  Then "Bottom of the Page" should be selected for "page[editable_elements_attributes][0][content]"
  When I select "Top of the Page" from "page[editable_elements_attributes][0][content]"
  And I press "Save"
  Then I should see "Page was successfully updated."
  When I reload the page
  Then "Top of the Page" should be selected for "page[editable_elements_attributes][0][content]"