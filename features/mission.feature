Feature: Mission Features

  Scenario: Viewing an existing mission
    When I view a mission
    Then I see that mission

  Scenario: Adding a new mission
    Given I am on the mission index
    When I click add mission
    Then I can create a new mission
    And I can see that mission
