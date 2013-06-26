Feature: Localized Content Entries
  As an editor
  In order to manage translations of custom content entries
  I want to edit localized fields of custom contents of my site

Background:
  Given I have the site: "test site" set up with name: "test site"
  And the site "test site" has locales "en, de"
  And I have a custom model named "Proverbs" with
    | label       | type        | required    | localized   |
    | Proverb     | string      | true        | true        |
    | Author      | string      | false       | false       |
  And I have entries for "Proverbs" with
    | proverb                   | author    |
    | Jump on the bandwagon     | John      |
  And I am an authenticated user

Scenario: See original entry in list
  When I go to the list of "Proverbs"
  Then I should see "Jump on the bandwagon"
  And I should not see "untranslated"

@javascript
Scenario: See untranslated entry in list
  When I switch the locale to "de"
  And I go to the list of "Proverbs"
  Then I should see "Jump on the bandwagon"
  And I should see "untranslated"

Scenario: See original entry details
  When I go to the list of "Proverbs"
  And I follow "Jump on the bandwagon" within the main content
  Then the "Proverb" field should contain "Jump on the bandwagon"
  And the "Author" field should contain "John"

@javascript
Scenario: See untranslated entry details
  When I switch the locale to "de"
  And I go to the list of "Proverbs"
  And I follow "Jump on the bandwagon" within the main content
  Then the "Proverb" field should contain "Jump on the bandwagon"
  And the "Author" field should contain "John"

@javascript
Scenario: Translate entry
  When I switch the locale to "de"
  And I go to the list of "Proverbs"
  And I follow "Jump on the bandwagon" within the main content
  
  When I fill in "Proverb" with "Auf einen fahrenden Zug aufspringen"
  And I press "Save" within the main form
  Then I should see "Entry was successfully updated."
  
  When I go to the list of "Proverbs"
  Then I should see "Auf einen fahrenden Zug aufspringen"
  And I should not see "Jump on the bandwagon"
  And I should not see "untranslated"
  
  When I switch the locale to "en"
  And I go to the list of "Proverbs"
  Then I should not see "Auf einen fahrenden Zug aufspringen"
  And I should see "Jump on the bandwagon"
  And I should not see "untranslated"
