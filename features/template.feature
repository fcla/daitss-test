Feature: Submit and ingest the listed packages one at a time

  Scenario Outline: Submit and ingest the packagees below one at a time
    Given I goto "/submit"
    When I specifically select a <package> sip to upload
    And I press "Submit"
    And I click on "ingesting"
    And I choose "start"
    And I press "Update"
    And I wait for it to finish
    Examples:
	|package|
	|good|
