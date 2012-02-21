Feature: Snippets
  As a designer
  I want to insert re-usable piece of code among pages

Background:
  Given I have the site: "test site" set up
  And a snippet named "yield" with the template:
    """
    HELLO WORLD !
    """

Scenario: Simple include
  Given a page named "hello-world" with the template:
    """
    My application says {% include 'yield' %}
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application says HELLO WORLD !
    """