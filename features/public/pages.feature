Feature: Pages
  As a designer
  In order to improve my site navigation
  I want to list its pages

Background:
  Given I have the site: "test site" set up with name: "test site"

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
Scenario: link_to tag
  Given the site "test site" has locales "en, es"  
  And a page titled "About us" with the handle "about-us"
  And the page titled "About us" has the title "Acerca de" in the "es" locale
  And a page named "Page with links" with the template:
    """
    {% locale_switcher %}
    {% link_to about-us %}
    {% link_to_block about-us %}
      <i class="icon-info-sign"></i> {{ linked }}
    {% endlink_to_block %}
    """
  When I view the rendered page at "/page-with-links"
  Then show me the page
  Then the rendered output should look like:
    """
    <a href="/about-us">About us</a>
    <a href="/about-us">
      <i class="icon-info-sign"></i> About us
    </a>
    """
  When I follow "es"
  Then show me the page
  Then the rendered output should look like:
    """
    <a href="/es/acerca-de">About us</a>
    <a href="/es/acerca-de">
      <i class="icon-info-sign"></i> Acerca de
    </a>
    """