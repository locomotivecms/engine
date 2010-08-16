Feature: Engine
  As a designer
  I want to be able to build more complex page html layouts
  with shared template code
  that render correctly to the client

Background:
  Given I have the site: "test site" set up

Scenario: Liquid Inheritance with a single block
  Given a layout named "above_and_below" with the source:
    """
    <div class="header"></div>
    <div class="body">
      {% block body %}{% endblock %}
    </div>
    <div class="footer"></div>
    """

  And a page named "hello-world-with-layout" with the template:
    """
    {% extends 'above_and_below' %}
    {% block body %}Hello World{% endblock %}
    """

  When I view the rendered page at "/hello-world-with-layout"
  Then the rendered output should look like:
    """
    <div class="header"></div>
    <div class="body">
      Hello World
    </div>
    <div class="footer"></div>
    """

Scenario: Liquid Inheritance with multiple blocks
  Given a layout named "layout_with_sidebar" with the source:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">
        {% block sidebar %}DEFAULT SIDEBAR CONTENT{% endblock %}
      </div>
      <div class="body">
        {% block body %}DEFAULT BODY CONTENT{% endblock %}
      </div>
    </div>
    <div class="footer"></div>
    """
  And a page named "hello-world-multiblocks" with the template:
    """
    {% extends 'layout_with_sidebar' %}
    {% block body %}Hello world{% endblock %}
    """
  When I view the rendered page at "/hello-world-multiblocks"
  Then the rendered output should look like:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">
        DEFAULT SIDEBAR CONTENT
      </div>
      <div class="body">
        Hello world
      </div>
    </div>
    <div class="footer"></div>
    """

Scenario: Multiple inheritance (layout extending another layout)
  Given a layout named "layout_with_sidebar" with the source:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">{% block sidebar %}DEFAULT SIDEBAR CONTENT{% endblock %}</div>
      <div class="body">
        {% block body %}DEFAULT BODY CONTENT{% endblock %}
      </div>
    </div>
    <div class="footer"></div>
    """
  And a layout named "custom_layout_with_sidebar" with the source:
    """
    {% extends 'layout_with_sidebar' %}
    {% block sidebar %}Custom sidebar{% endblock %}
    {% block body %}Hello{% endblock %}
    """
  And a page named "hello-world-multiblocks" with the template:
    """
    {% extends 'custom_layout_with_sidebar' %}
    {% block body %}{{ block.super }} world{% endblock %}
    """
  When I view the rendered page at "/hello-world-multiblocks"
  Then the rendered output should look like:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">Custom sidebar</div>
      <div class="body">
        Hello world
      </div>
    </div>
    <div class="footer"></div>
    """


Scenario: Page extending a layout with multiple embedded blocks which extends another template
  Given a layout named "layout_with_sidebar" with the source:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">{% block sidebar %}DEFAULT SIDEBAR CONTENT{% endblock %}</div>
      <div class="body">
        {% block body %}Hello{% endblock %}
      </div>
    </div>
    <div class="footer"></div>
    """
  And a layout named "custom_layout_with_sidebar" with the source:
    """
    {% extends 'layout_with_sidebar' %}
    {% block body %}{{ block.super }} {% block main %}mister{% endblock %}{% endblock %}
    """
  And a page named "hello-world-multiblocks" with the template:
    """
    {% extends 'custom_layout_with_sidebar' %}
    {% block main %}{{ block.super }} Jacques{% endblock %}
    """
  When I view the rendered page at "/hello-world-multiblocks"
  Then the rendered output should look like:
    """
    <div class="header"></div>
    <div class="content">
      <div class="sidebar">DEFAULT SIDEBAR CONTENT</div>
      <div class="body">
        Hello mister Jacques
      </div>
    </div>
    <div class="footer"></div>
    """
