Feature: Install LocomotiveCMS
  In order to get LocomotiveCMS working
  I want to create Admin account
  And first site
  With respect to chosen locale

Scenario: Install Locomotive with Russian locale
	When I go to pages
	Then I should see "Create account"
	And I fill in the following:
	| Account name | Admin |
	| Email | admin@example.com |
	| account[password] | easyone |
	| account[password_confirmation] | easyone |

	When I press "Create account"

	Then I should see "Create your first site"
	And I fill in "FirstSite" for "Name"
	And I fill in "cool" for "Subdomain"
	And I select "Russian" from "Site locale"

	When I press "Create site"

	Then I should see "Войти"
	And I fill in the following:
		| Email | admin@example.com |
		| Пароль | easyone |

	When I press "Войти"
	Then I should see "Список страниц"
	And I should not see "Home page"
	And I should see "Стартовая страница"