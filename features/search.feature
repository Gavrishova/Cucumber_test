Feature: Search  hotels
  As an user
  I want to find hotel for some date

  Background:
    Given I navigate to site

   Scenario: Search cheapest hotel with image for some date
    When I  type the city
    And Select date
    And Press search button
    And Sort the page by price
    Then I have the cheapest hotel with image available on the page
