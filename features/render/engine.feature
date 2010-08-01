Feature: Engine
  As a website user
  I want to be able to view someones created locomotive pages

Background:
  Given I have the site: "test site" set up

Scenario: Simple Page
  Given I have a simple page at "hello-world" with the body:
    """
    Hello World
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    Hello World
    """

Scenario: Simple Page with layout
  Given a layout named "above_and_below" with the body:
      """
      <div class="up_above"></div>
      {{ content_for_layout }}
      <div class="down_below"></div>
      """

  And I have a simple page at "/hello-world-with-layout" with the layout "above_and_below" and the body:
    """
    Hello World
    """

  When I view the rendered page at "/hello-world-with-layout"
  Then the rendered output should look like:
    """
    <div class="up_above"></div>
    Hello World
    <div class="down_below"></div>
    """

Scenario: Layout with Parts



