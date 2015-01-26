Feature: API for hotels
  As an API user
  I want to order hotel


  @api
  Scenario: Search hotel
    Given I expect response time to be 2 sec
    And I send and accept JSON
    When I send a GET request to "/suggestRequest" with the following:
      | lang  | ru   |
      | query | Mosc |
    And the response status should be "200"
    And I remember response time
    And I remember id of city
    And I use the saved id of city and random date
    And I send a GET request to "/searchRequest" with the following:
      | lang     | ru  |
      | adults   | 1   |
      | children | 0   |
      | currency | USD |
    And the response status should be "200"
    And I remember response time
    And I save the request id
    And Add request id to request
    And I send a GET request to "/searchPolling" with the following:
      | lang | ru |
    And the response status should be "200"
    And I remember response time
    And I check the status of response
    And I save the id of hotels
    And I use the saved id of hotel and random date
    And I send a GET request to "/offersRequest" with the following:
      | lang     | ru  |
      | currency | USD |
    And I check the provider
    And the response status should be "200"
    And I remember response time
    And I save the token of provider
    And I use the saved token of provider
    And I send a GET request to "/policyRequest" with the following:
      | lang | ru |
    And the response status should be "200"
    And I remember response time
    Then I should see correct offer

