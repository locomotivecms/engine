Feature: Contact form
  As a visitor
  In order to keep in touch with the site
  I want to be able to send them a message

  Background:
    Given I enable the CSRF protection for public submission requests
    Given I have the site: "test site" set up
    And I have a custom model named "Messages" with
      | label       | type      | required    |
      | Email       | string    | true        |
      | Message     | text      | true        |
      | Category    | select    | true        |
    And I have "Design, Code, Business" as "Category" values of the "Messages" model
    And I enable the public submission of the "Messages" model
    And a page named "contact" with the template:
      """
      <html>
        <head></head>
        <body>
          <form action="{{ contents.messages.public_submission_url }}" method="post">
            {% csrf_param %}
            <input type="hidden" value="/success" name="success_callback" />
            <input type="hidden" value="/contact" name="error_callback" />
            <label for="email">E-Mail Address</label>
            <input type="text" id="email" name="content[email]" />
            {% if message.errors.email %}Email is required{% endif %}
            <label for="category">Category</label>
            <select id="category" name="content[category]">
              <option value=""></option>
              {% for name in contents.messages.category_options %}
              <option value="{{ name }}">{{ name }}</option>
              {% endfor %}
            </select>
            <label for="message">Message</label>
            <textarea name="content[message]" id="message"></textarea>
            <input name="submit" type="submit" id="submit" value="Submit" />
          </form>
        </body>
      </html>
      """
    And a page named "success" with the template:
      """
      Thanks {{ message.email }}
      """

  Scenario: Setting the right url for the contact form
    When I view the rendered page at "/contact"
    Then the rendered output should look like:
      """
      <form action="/entry_submissions/messages" method="post">
      """

  Scenario: Prevents users to post messages if the public submission option is disabled
    Given I disable the public submission of the "Messages" model
    When I view the rendered page at "/contact"
    And I fill in "E-Mail Address" with "did@locomotivecms.com"
    And I fill in "Message" with "LocomotiveCMS rocks"
    And I press "Submit"
    Then I should not see "Thanks did@locomotivecms.com"

  Scenario: Sending a message with success
    When I view the rendered page at "/contact"
    And I fill in "E-Mail Address" with "did@locomotivecms.com"
    And I fill in "Message" with "LocomotiveCMS rocks"
    And I select "Code" from "Category"
    And I press "Submit"
    Then I should see "Thanks did@locomotivecms.com"

  Scenario: Can not send a message if the csrf tag is missing
    Given I delete the following code "{% csrf_param %}" from the "contact" page
    When I view the rendered page at "/contact"
    And I press "Submit"
    Then I should see "Content of the home page"

  Scenario: Can send a message if the csrf protection is disabled
    Given I disable the CSRF protection for public submission requests
    And I view the rendered page at "/contact"
    And I fill in "E-Mail Address" with "did@locomotivecms.com"
    And I fill in "Message" with "LocomotiveCMS rocks"
    And I select "Code" from "Category"
    And I press "Submit"
    Then I should see "Thanks did@locomotivecms.com"

  Scenario: Display errors
    When I view the rendered page at "/contact"
    And I fill in "Message" with "LocomotiveCMS rocks"
    And I press "Submit"
    Then I should see "Email is required"

  Scenario: Make sure to use the right locale
    When I view the rendered page at "/contact"
    And the locale of the current ruby thread changes to "fr"
    And I fill in "E-Mail Address" with "did@locomotivecms.com"
    And I fill in "Message" with "LocomotiveCMS rocks"
    And I select "Code" from "Category"
    And I press "Submit"
    Then I should see "Thanks did@locomotivecms.com"
