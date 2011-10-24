Feature: Has Many Association
  As a designer
  In order to make dealing with models easier
  I want to be able to display other models that have a has many association

  Background:
    Given I have the site: "test site" set up

  Scenario: Paginating a has many association
    Given I have an "Articles" model which has many "Comments"
    Then I should be able to view a paginated list of "Comments" per "Articles"
