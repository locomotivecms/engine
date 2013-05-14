Feature: Engine
  As a designer
  I want to be able to build simple page html layouts
  that render correctly to the client

Background:
  Given I have the site: "test site" set up

Scenario: Simple Page
  Given a page named "hello-world" with the template:
    """
    Hello World
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    Hello World
    """

Scenario: Missing 404 page
  Given a page named "hello-world" with the template:
    """
    Hello World
    """
  And the page "404" is unpublished
  When I view the rendered page at "/madeup"
  Then the rendered output should look like:
    """
    No Page!
    """