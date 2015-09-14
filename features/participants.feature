Feature: Participation

  Scenario: I can add a user to a mission
    Given I have a mission
      And I view the mission
    When I add a user to the Mission
    Then the user should be apart of the mission

  Scenario: I can remove user from a mission
    # waiting for email login
