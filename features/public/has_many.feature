Feature: Has Many Association
  As a designer
  In order to make dealing with models easier
  I want to be able to display other models that have a has many association

  Scenario: Paginating a has many association
    Given I have a site set up
    Then I should be able to view a paginated list of a has many association
