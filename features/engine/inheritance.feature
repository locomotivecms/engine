Scenario: Simple Page extending a layout with multiple embedded blocks which extends another template
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
