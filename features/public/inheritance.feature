Feature: Inheritance
  As a designer
  I want to be able to build more complex page html layouts
  with shared template code
  that render correctly to the client

Background:
  Given I have the site: "test site" set up

Scenario: Liquid Inheritance with a single block
  Given a page named "above-and-below" with the template:
    """
    <div class="header"></div>
    <div class="body">
      {% block body %}{% endblock %}
    </div>
    <div class="footer"></div>
    """
  And a page named "hello-world-with-layout" with the template:
    """
    {% extends 'above-and-below' %}
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

Scenario: Update a parent page and see modifications in descendants
  Given a page named "base" with the template:
    """
    My application say: {% block something %}Lorem ipsum{% endblock %}
    """
  And a page named "hello-world" with the template:
    """
    {% extends 'base' %}
    {% block something %}Hello World{% endblock %}
    """
  When I update the "base" page with the template:
    """
    My application says: {% block something %}Lorem ipsum{% endblock %}
    """
  When I view the rendered page at "/hello-world"
  Then the rendered output should look like:
    """
    My application says: Hello World
    """

Scenario: Liquid Inheritance with multiple blocks
  Given a page named "layout-with-sidebar" with the template:
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
    {% extends 'layout-with-sidebar' %}
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
  Given a page named "layout-with-sidebar" with the template:
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
  And a page named "custom-layout-with-sidebar" with the template:
    """
    {% extends 'layout-with-sidebar' %}
    {% block sidebar %}Custom sidebar{% endblock %}
    {% block body %}Hello{% endblock %}
    """
  And a page named "hello-world-multiblocks" with the template:
    """
    {% extends 'custom-layout-with-sidebar' %}
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
  Given a page named "layout-with-sidebar" with the template:
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
  And a page named "custom-layout-with-sidebar" with the template:
    """
    {% extends 'layout-with-sidebar' %}
    {% block body %}{{ block.super }} {% block main %}mister{% endblock %}{% endblock %}
    """
  And a page named "hello-world-multiblocks" with the template:
    """
    {% extends 'custom-layout-with-sidebar' %}
    {% block body/main %}{{ block.super }} Jacques{% endblock %}
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
