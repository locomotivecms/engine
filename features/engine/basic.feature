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

# Scenario: Page with Parts
#   Given a layout named "layout_with_sidebar" with the source:
#     """
#     <div class="header"></div>
#     <div class="content">
#       <div class="sidebar">{{ content_for_sidebar }}</div>
#       <div class="body">
#         {{ content_for_layout }}
#       </div>
#     </div>
#     <div class="footer"></div>
#     """
#   And a page named "hello-world-multipart" with the layout "layout_with_sidebar" and the body:
#     """
#     IM IN UR BODY OUTPUTTING SUM CODEZ!!
#     """
#
#   And the page named "hello-world-multipart" has the part "sidebar" with the content:
#     """
#     IM IN UR SIDEBAR PUTTING OUT LINKZ
#     """
#
#   When I view the rendered page at "/hello-world-multipart"
#   Then the rendered output should look like:
#     """
#     <div class="header"></div>
#     <div class="content">
#       <div class="sidebar">IM IN UR SIDEBAR PUTTING OUT LINKZ</div>
#       <div class="body">
#         IM IN UR BODY OUTPUTTING SUM CODEZ!!
#       </div>
#     </div>
#     <div class="footer"></div>
#     """
#
# @wip
# Scenario: Simple Page with Admin Inline Editing
#   Given a simple page named "hello-world-inline" with the body:
#     """
#     {% block hello %}Hello World{% endblock %}
#     """
#   When And I'm an admin
#   And I view the rendered page at "/hello-world-inline"
#   Then the rendered output shoud look like:
#     """
#     <div class="inline-editing" data-url="/admin/parts/XXXX" data-title="hello">Hello World</div>
#     """

# {% block main %}Didier{% endblock %}

    # {% block body %}{% block main %}{{ block.super }}Jacques{% endblock %}{% endblock %}
    # {% block body %}Hello mister Jacques{% endblock %}