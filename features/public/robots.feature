Feature: Robots
  As a designer
  I want to be able to define a robots.txt file for my site

Background:
  Given I have the site: "test site" set up

Scenario: Simple robots text
  Given a robot_txt set to "robots text value"
  When I view the rendered page at "/robots.txt"
  Then the rendered output should look like:
    """
    robots text value
    """

Scenario: Robots.txt should provide access to request_host and all other liquid variables
  Given a robot_txt set to "host: {{request_host}} path: {{path}}"
  When I view the rendered page at "/robots.txt"
  Then the rendered output should look like:
    """
    host: test.example.com path: /robots.txt
    """
