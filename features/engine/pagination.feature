Feature: Pagination
  As a designer
  In order to display a sensible amount of items per page
  I want to be able to paginate through models

  Scenario: Paginating through a model
    Given I have a site setup
    Then I should be able to display paginated models
