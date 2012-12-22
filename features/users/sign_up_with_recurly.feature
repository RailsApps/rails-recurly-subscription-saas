Feature: User signs up with Recurly
  Note: you must have Recurly setup with silver plan
  for these tests to run correctly.

  Background:
    Given: I am on the home page
    When I follow the subscribe for silver path
    Then I should see "Silver Subscription Plan"

  @javascript
  Scenario: With valid card data
    Given I fill in the following:
      | user_first_name            | Testy             |
      | user_last_name             | McUserson         |
      | Email                      | testy@testing.com |
      | user_password              | secret_password   |
      | user_password_confirmation | secret_password   |
      | Credit Card Number         | 4111111111111111  |
      | card_code                  | 111               |
    Then I select "5 - May" as the "month"
    And I select "2015" as the "year"
    When I press "Sign up"
    Then I should be on the "content silver" page
    And I should see a successful sign up message

  @javascript
  Scenario: With invalid card number
    Given I fill in the following:
      | user_first_name            | Testy             |
      | user_last_name             | McBadCard         |
      | Email                      | testy@testing.com |
      | user_password              | secret_password   |
      | user_password_confirmation | secret_password   |
      | Credit Card Number         | 5555555555555     |
      | card_code                  | 111               |
    Then I select "1 - January" as the "month"
    And I select "2016" as the "year"
    When I press "Sign up"
    Then I should be on the new silver user registration page
    And I should see "Billing info number is not a valid credit card number"

  @javascript
  Scenario: With invalid card security code
    Given I fill in the following:
      | user_first_name            | Testy             |
      | user_last_name             | McBadCode         |
      | Email                      | testy@testing.com |
      | user_password              | secret_password   |
      | user_password_confirmation | secret_password   |
      | Credit Card Number         | 4111111111111111  |
      | card_code                  | 6                 |
    Then I select "10 - October" as the "month"
    And I select "2016" as the "year"
    When I press "Sign up"
    Then I should be on the new silver user registration page
    And I should see "Billing info verification value must be three or four digits"

    @javascript
    Scenario: With declined card
      Given I fill in the following:
        | user_first_name            | Testy             |
        | user_last_name             | McDecline         |
        | Email                      | testy@testing.com |
        | user_password              | secret_password   |
        | user_password_confirmation | secret_password   |
        | Credit Card Number         | 4000000000000002  |
        | card_code                  | 111               |
      Then I select "10 - October" as the "month"
      And I select "2016" as the "year"
      When I press "Sign up"
      Then I should be on the new silver user registration page
      And I should see "The transaction was declined"


