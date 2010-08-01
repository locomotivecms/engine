Feature: Engine
  As a website user
  I want to be able to view someones created locomotive pages

Background:
  Given I have the site: "test site" set up

Scenario: Simple Page
  Given a simple page named "hello-world" with the body:
    """
    Hello World
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    Hello World
    """

Scenario: Simple Page with layout
  Given a layout named "above_and_below" with the source:
    """
    <div class="header"></div>
    {{ content_for_layout }}
    <div class="footer"></div>
    """

  And a page named "hello-world-with-layout" with the layout "above_and_below" and the body:
    """
    Hello World
    """

  When I view the rendered page at "/hello-world-with-layout"
  Then the rendered output should look like:
    """
    <div class="header"></div>
    Hello World
    <div class="footer"></div>
    """

Scenario: Page with Parts
  Given a layout named "layout_with_sidebar" with the source:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">{{ content_for_sidebar }}</div>
      <div class="body">
        {{ content_for_layout }}
      </div>
    </div>
    <div class="footer"></div>
    """
  And a page named "hello-world-multipart" with the layout "layout_with_sidebar" and the body:
    """
    IM IN UR BODY OUTPUTTING SUM CODEZ!!
    """

  And the page named "hello-world-multipart" has the part "sidebar" with the content:
    """
    IM IN UR SIDEBAR PUTTING OUT LINKZ
    """

  When I view the rendered page at "/hello-world-multipart"
  Then the rendered output should look like:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">IM IN UR SIDEBAR PUTTING OUT LINKZ</div>
      <div class="body">
        IM IN UR BODY OUTPUTTING SUM CODEZ!!
      </div>
    </div>
    <div class="footer"></div>
    """
