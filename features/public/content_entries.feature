Feature: Content entries
  As a designer
  I want to list and filter the entries of a
  content type I designed through to the back-office and
  I should be able to display the entries from a liquid template

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Articles" with
    | label         | type      | required    |
    | Title         | string    | true        |
    | Body          | string    | false       |
    | Hidden        | boolean   | false       |
    | Published at  | date      | false       |
  And I have entries for "Articles" with
    | title             | body                    | published_at  | hidden  |
    | Hello world       | Lorem ipsum             | 2015-01-01    | false   |
    | Lorem ipsum       | Lorem ipsum...          | 2013-03-23    | false   |
    | Yadi Yada         | Lorem ipsum...          | 2013-03-23    | true    |

Scenario: List all of them
  Given a page named "my-articles" with the template:
    """
    {% for article in contents.articles %}{{ article.title }}, {% endfor %}
    """
  When I view the rendered page at "/my-articles"
  Then the rendered output should look like:
    """
    Hello world, Lorem ipsum, Yadi Yada
    """

Scenario: Filter by a boolean
  Given a page named "my-articles" with the template:
    """
    {% with_scope hidden: false %}
    {% for article in contents.articles %}{{ article.title }}, {% endfor %}
    {% endwith_scope %}
    """
  When I view the rendered page at "/my-articles"
  Then the rendered output should look like:
    """
    Hello world, Lorem ipsum
    """

Scenario: Filter by a date
  Given a page named "my-articles" with the template:
    """
    {% with_scope published_at.lte: now %}
    {% for article in contents.articles %}{{ article.title }}, {% endfor %}
    {% endwith_scope %}
    """
  When I view the rendered page at "/my-articles"
  Then the rendered output should look like:
    """
    Lorem ipsum, Yadi Yada
    """
    
Scenario: Filter with regexp
  Given a page named "my-articles" with the template:
    """
    {% with_scope title: /ello|adi/ %}
    {% for article in contents.articles %}{{ article.title }}, {% endfor %}
    {% endwith_scope %}
    """
  When I view the rendered page at "/my-articles"
  Then the rendered output should look like:
    """
    Hello world, Yadi Yada
    """