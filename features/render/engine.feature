Feature: Engine
  As a website user
  I want to be able to view someones created locomotive pages

  Background:
    Given I have the site: "test site" set up

  Scenario: Simple Page
    Given I have a simple page created at "hello-world" with the body:
      """
      Hello World
      """
    When I view the rendered page at "/hello-world"
    Then the rendered output should look like:
      """
      Hello World
      """

  @wip
  Scenario: Page with layout
    Given a layout named "above_and_below" with the content:
        """
        <div class="up_above"></div>
        {{ content_for_layout }}
        <div class="down_below"></div>
        """

    And a page at "/hello_world_layout" with the layout "above_and_below" and the content:
      """
      Hello World
      """

    When I render "/hello_world_layout"
    Then the rendered output should look like:
      """
      <div class="up_above"></div>
      Hello World
      <div class="down_below"></div>
      """



