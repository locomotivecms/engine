Feature: Pages
  As a designer
  In order to improve my site navigation
  I want to list its pages

Background:
  Given I have the site: "test site" set up with name: "test site"

Scenario: List all of them
  Given a page named "all" with the template:
    """
    {% for page in site.pages %}{{ page.title }}, {% endfor %}
    """
  When I view the rendered page at "/all"
  Then the rendered output should look like:
    """
    Home page, All, Page not found,
    """

Scenario: Scoped listing
  Given a page named "hidden-page" with the template:
    """
    Hidden content
    """
  And the page "hidden-page" is unpublished
  And a page named "hidden-pages" with the template:
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
  And a page named "about-us" with the handle "about-us"
  And the page named "about-us" has the title "Acerca de" in the "es" locale
  And a page named "page-with-links" with the template:
    """
    {% locale_switcher %}
    {% link_to about-us %}
    {% link_to about-us, locale: es %}
    {% link_to about-us %}
      <i class="icon-info-sign"></i> {{ target.title }}
    {% endlink_to %}
    """
  And the page named "page-with-links" has the title "Página con links" in the "es" locale
  When I view the rendered page at "/page-with-links"
  Then the rendered output should look like:
    """
    <a href="/about-us">About us</a>
    <a href="/es/acerca-de">Acerca de</a>
    <a href="/about-us">
      <i class="icon-info-sign"></i> About us
    </a>
    """
  When I follow "es"
  Then the rendered output should look like:
    """
    <a href="/es/acerca-de">Acerca de</a>
    <a href="/es/acerca-de">Acerca de</a>
    <a href="/es/acerca-de">
      <i class="icon-info-sign"></i> Acerca de
    </a>
    """

Scenario: link_to templatized page
  Given I have a custom model named "Articles" with
      | label       | type      | required    |
      | Title       | string    | true        |
  And I have entries for "Articles" with
    | title             |
    | Hello world       |
  And a templatized page for the "Articles" model and with the template:
    """
    Here is the title: "{{ article.title }}"
    """
  And a page named "page-with-links" with the template:
    """
    {% for article in contents.articles %}
      Link to article: {% link_to article %}
    {% endfor %}
    """
  When I view the rendered page at "/page-with-links"
  And I follow "Hello world"
  Then the rendered output should look like:
  """
  Here is the title: "Hello world"
  """
    
Scenario: Default locale fallback
  Given the site "test site" has locales "en, es"
  And a page named "only-english" with the template:
    """
    Only english, please
    """
  When I view the rendered page at "/es/only-english"
  Then I should see "Only english, please"


Scenario: fetch_page tag
  Given a page named "print-the-slug-of-a-page" with the template:
    """
    {% fetch_page this-is-the-page-handle as my_page %}
    {{ my_page.slug }}
    """
  And a page named "this-is-the-slug" with the handle "this-is-the-page-handle"
  When I view the rendered page at "/print-the-slug-of-a-page"
  Then the rendered output should look like:
    """
    this-is-the-slug
    """