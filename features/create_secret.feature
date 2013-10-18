Feature: Creating secrets

  Scenario: Anonymous users cannot create secrets
    When I try to create a secret
    Then I am not authenticated

  Scenario: Alice can create a secret
    Given I am logged in as "alice"
    When I try to create a secret
    Then it is allowed

  Scenario: Bob cannot create a secret
    Given I am logged in as "bob"
    When I try to create a secret
    Then it is denied

  Scenario: Host-A cannot create a secret
    Given I am logged in as "host/a"
    When I try to create a secret
    Then it is denied
    