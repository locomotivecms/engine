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
