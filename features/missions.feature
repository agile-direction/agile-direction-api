Feature: Missions

  Scenario: I should be able to see Missions
    When I have missions
    Then I should see missions

  Scenario: I should be able to see a Mission
    When I view a mission
    Then I see that mission

  Scenario: I should be able to create a Mission
    When I create a mission
    Then I see that mission
      And I should be prompted to "add deliverable"

  Scenario: I should be able to update a Mission
    When I update a mission
    Then I see that mission

  Scenario: I should be able to clone a Mission
    Given I have a mission
    When I clone the mission
    Then I should see a cloned mission

