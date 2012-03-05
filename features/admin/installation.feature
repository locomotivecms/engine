Feature: Installation
  As A User
  In order to get setup with locomotive quickly
  I want to be able to create an admin account and my first site


  Scenario: Viewing the installation deatils after creating a site (Bug)
    Given I have a site set up
    When I am on the installation page
    Then I should not be able to see any admin user details
