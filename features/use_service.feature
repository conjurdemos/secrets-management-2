Feature: Using the provisioning service

  Scenario: Anonymous users cannot use the service
    When I try to use the secret
    Then I am not authenticated

  Scenario: Alice cannot use the service
    Given I am logged in as "alice"
    When I check my permission to "execute" the "layer" resource named "provision" 
    Then it is refused

  Scenario: Bob can use the service
    Given I am logged in as "bob"
    When I check my permission to "execute" the "layer" resource named "provision" 
    Then it is confirmed

  Scenario: Host-A cannot use the service
    Given I am logged in as "host/a"
    When I check my permission to "execute" the "layer" resource named "provision" 
    Then it is refused
