Feature: Editable elements
  As a designer
  I want to define content which will be edited by the website editor

Background:
  Given I have the site: "test site" set up

Scenario: Simple short text element
  Given a page named "hello-world" with the template:
    """
    My application says {% editable_short_text 'a_sentence', hint: 'please enter a new sentence' %}Hello world{% endeditable_short_text %}
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application says Hello world
    """

Scenario: Updating a page
  Given a page named "hello-world" with the template:
    """
    My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}
    {% block main %}Main{% endblock %}
    """
  When I update the "hello-world" page with the template:
    """
    My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}
    {% block main %}Main{% endblock %}
    {% block sidebar %}{% editable_short_text 'title' %}Default sidebar title{% endeditable_short_text %}{% endblock %}
    """
  And I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application says Hello world
    Main
    Default sidebar title
    """

Scenario: Modified short text element
  Given a page named "hello-world" with the template:
    """
    My application says {% editable_short_text 'a_sentence', hint: 'please enter a new sentence' %}Hello world{% endeditable_short_text %}
    """
  And the editable element "a_sentence" in the "hello-world" page with the content "Bonjour"
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application says Bonjour
    """

Scenario: Short text element inside a block
  Given a page named "hello-world" with the template:
    """
    {% block main %}My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}{% endblock %}
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application says Hello world
    """

Scenario: Not modified short text element inside a block and with page inheritance
  Given a page named "hello-world" with the template:
    """
    {% block main %}My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}{% endblock %}
    """
  Given a page named "another-hello-world" with the template:
    """
    {% extends hello-world %}
    """
  When I view the rendered page at "/another-hello-world"
  Then the rendered output should look like:
    """
    My application says Hello world
    """

Scenario: Modified short text element inside a block and with page inheritance
  Given a page named "hello-world" with the template:
    """
    {% block main %}My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}{% endblock %}
    """
  Given a page named "another-hello-world" with the template:
    """
    {% extends hello-world %}
    """
  And the editable element "a_sentence" for the "main" block in the "another-hello-world" page with the content "Bonjour"
  When I view the rendered page at "/another-hello-world"
  Then the rendered output should look like:
    """
    My application says Bonjour
    """

Scenario: Combine inheritance and update
  Given a page named "hello-world" with the template:
    """
    My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}
    {% block main %}Main{% endblock %}
    """
  Given a page named "another-hello-world" with the template:
    """
    {% extends hello-world %}
    {% block main %}Another Main{% endblock %}
    """
  When I update the "hello-world" page with the template:
    """
    My application says {% editable_short_text 'a_sentence' %}Hello world{% endeditable_short_text %}
    {% block main %}Main{% endblock %}
    {% block sidebar %}{% editable_short_text 'title' %}Default sidebar title{% endeditable_short_text %}{% endblock %}
    """
  And I view the rendered page at "/another-hello-world"
  Then the rendered output should look like:
    """
    My application says Hello world
    Another Main
    Default sidebar title
    """

Scenario: Insert editable files
  Given a page named "hello-world" with the template:
    """
    My application file is {% editable_file 'a_file', hint: 'please enter a new file' %}/default.pdf{% endeditable_file %}
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application file is /default.pdf
    """

Scenario: Simple select element
  Given a page named "hello-world" with the template:
    """
    {% block menuecontent %}{% editable_control 'menueposition', options: 'top=Top of the Page,bottom=Bottom of the Page' %}bottom{% endeditable_control %}{% endblock %}
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    bottom
    """