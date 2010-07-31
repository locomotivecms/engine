Feature: Engine
  As a website user
  I want to be able to view someones created locomotive pages

  @wip
  Scenario: Simple Page
    Given I have a page created at "/hello_world" with the content:
      """
      Hello World
      """
    When I render "/hello_world"
    Then output should look like
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
    Then output should look like
      """
      <div class="up_above"></div>
      Hello World
      <div class="down_below"></div>
      """



