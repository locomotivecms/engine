Feature: Many to Many Association
  As a designer
  In order to make dealing with models easier
  I want to be able to display other models that have a many to many association

  Background:
    Given I have the site: "test site" set up
    And I have a custom model named "Articles" with
      | label       | type      | required    |
      | Title       | string    | true        |
      | Body        | string    | false       |
    And I have a custom model named "Projects" with
      | label       | type      | required    | target  |
      | Name        | string    | true        |         |
      | Description | text      | false       |         |
    And I set up a many_to_many relationship between "Articles" and "Projects"
    And I have entries for "Articles" with
      | title             | body                    |
      | Hello world       | Lorem ipsum             |
      | Lorem ipsum       | Lorem ipsum...          |
    And I have entries for "Projects" with
      | name              | description             |
      | My sexy project   | Lorem ipsum             |
      | Foo project       | Lorem ipsum...          |
      | Bar project       | Lorem ipsum...          |
      | Baz project       | Lorem ipsum...          |
    And I attach the "My sexy project" project to the "Hello world" article
    And I attach the "Baz project" project to the "Hello world" article
    And I attach the "Foo project" project to the "Hello world" article

  Scenario: Displaying the entries of a many to many association
    Given a page named "article-projects" with the template:
      """
      {% assign article = contents.articles.first %}
      <h1>Projects for {{ article.title }}</h1>
      <ul>
      {% for project in article.projects %}<li>{{ project.name }}</li>
      {% endfor %}
      </ul>
      """
    When I view the rendered page at "/article-projects"
    Then the rendered output should look like:
      """

      <h1>Projects for Hello world</h1>
      <ul>
      <li>My sexy project</li>
      <li>Baz project</li>
      <li>Foo project</li>

      </ul>
      """

  Scenario: Displaying the entries of a many to many association by a different thread
    Given the "Projects" model was created by another thread
    And a page named "article-projects" with the template:
      """
      {% assign article = contents.articles.first %}{% for project in article.projects %}{{ project.name }}, {% endfor %}
      """
    When I view the rendered page at "/article-projects"
    Then the rendered output should look like:
      """
      My sexy project, Baz project, Foo project
      """