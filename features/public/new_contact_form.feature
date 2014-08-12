Feature: Contact form [New way]
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
          {% if message %}Thanks {{ message.email }}{% endif %}
          {% model_form "messages" %}
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
          {% endmodel_form %}
        </body>
      </html>
      """
    And a page named "contact_with_redirection" with the template:
      """
      <html>
        <head></head>
        <body>
          {% model_form "messages", success: "/success" %}
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
          {% endmodel_form %}
        </body>
      </html>
      """
    And a page named "success" with the template:
      """
      Thanks {{ message.email }}!
      """

  Scenario: Use the url of the current page for the contact form
    When I view the rendered page at "/contact"
    Then the rendered output should look like:
      """
      <form method="POST" enctype="multipart/form-data">
      """

  Scenario: Sending a message with success
    When I view the rendered page at "/contact"
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

  Scenario: Redirection after success
    When I view the rendered page at "/contact_with_redirection"
    And I fill in "E-Mail Address" with "estelle@locomotivecms.com"
    And I fill in "Message" with "LocomotiveCMS rocks"
    And I select "Code" from "Category"
    And I press "Submit"
    Then I should see "Thanks estelle@locomotivecms.com!"
