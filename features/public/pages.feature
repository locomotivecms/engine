Feature: Pages
  As a designer
  In order to improve my site navigation
  I want to list its pages

Background:
  Given I have the site: "test site" set up

Scenario: List all of them
  Given a page named "All" with the template:
    """
    {% for page in site.pages %}{{ page.title }}, {% endfor %}
    """
  When I view the rendered page at "/all"
  Then the rendered output should look like:
    """
    Home page, some title, Page not found, 
    """

Scenario: Scoped listing
  Given a page named "Hidden page" with the template:
    """
    Hidden content
    """
  And the page "hidden-page" is unpublished
  And a page named "Hidden pages" with the template:
    """
    {% with_scope published: false %}
      {% for page in site.pages %}{{ page.slug }}, {% endfor %}
    {% endwith_scope %}
    """
  When I view the rendered page at "/hidden-pages"
  Then the rendered output should look like:
    """
    hidden-page,
    """