Feature: Session
  As a designer
  I want to record objects in the session and reach them later

Background:
  Given I have the site: "test site" set up
  And a page named "store" with the template:
    """
    Store a string in the session. {% session_assign foo = 'monkey' %}
    """
  And a page named "retrieve" with the template:
    """
    Retrieve a string from the session: {{ session.foo }}.
    """
  And a page named "release" with the template:
    """
    Remove a string from the session. {% session_assign foo = null %}
    """

Scenario: Store and retrieve a string in session
  When I view the rendered page at "/retrieve"
  Then the rendered output should look like:
    """
    Retrieve a string from the session: .
    """
  When I view the rendered page at "/store"
  And I view the rendered page at "/retrieve"
  Then the rendered output should look like:
    """
    Retrieve a string from the session: monkey.
    """

Scenario: Remove a object from the session
  When I view the rendered page at "/store"
  And I view the rendered page at "/release"
  And I view the rendered page at "/retrieve"
  Then the rendered output should look like:
    """
    Retrieve a string from the session: .
    """