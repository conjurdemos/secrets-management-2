Feature: Using secrets

  Scenario: Anonymous users cannot use secrets
    When I try to use the secret
    Then I am not authenticated

  Scenario: Alice can use a secret
    Given I am logged in as "alice"
    When I try to use the secret
    Then it is allowed

  Scenario: Bob cannot use a secret
    Given I am logged in as "bob"
    When I try to use the secret
    Then it is denied

  Scenario: Host-A can use a secret
    Given I am logged in as "host/a"
    When I try to use the secret
    Then it is allowed
