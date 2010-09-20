Feature: A submission and subsequent ingest operation of a known good package
  should result in a successful ingest. 

  Scenario Outline: A submission and ingest of a known good package by an operator
    Given I goto "/submit"
    When I specifically select a <package> sip to upload
    And I press "Submit"
    And I click on "ingesting"
    And I choose "start"
    And I press "Update"
    And I wait for it to finish
    Then the ingest time is output
    Examples:
	|package|
	|good|
  |sizes_under_10files_1|
  |sizes_under_10files_2|
  |sizes_under_10files_3|
  |sizes_10-19files_1|
  |sizes_10-19files_2|
  |sizes_10-19files_3|
  |sizes_20-29files_1|
  |sizes_20-29files_2|
  |sizes_20-29files_3|
  |sizes_30-39files_1|
  |sizes_30-39files_2|
  |sizes_30-39files_3|
  |sizes_40-49files_1|
  |sizes_40-49files_2|
  |sizes_40-49files_3|
  |sizes_50-59files_1|
  |sizes_50-59files_2|
  |sizes_50-59files_3|
  |sizes_60-69files_1|
  |sizes_60-69files_2|
  |sizes_60-69files_3|
  |sizes_70-79files_1|
  |sizes_70-79files_2|
  |sizes_70-79files_3|
  |sizes_80-89files_1|
  |sizes_80-89files_2|
  |sizes_80-89files_3|
  |sizes_90-99files_1|
  |sizes_90-99files_2|
  |sizes_90-99files_3|
  |sizes_100-199files_1|
  |sizes_100-199files_2|
  |sizes_100-199files_3|
  |sizes_200-299files_1|
  |sizes_200-299files_2|
  |sizes_200-299files_3|
  |sizes_300-399files_1|
  |sizes_300-399files_2|
  |sizes_300-399files_3|
  |sizes_400-499files_1|
  |sizes_400-499files_2|
  |sizes_400-499files_3|
  |sizes_500-599files_1|
  |sizes_500-599files_2|
  |sizes_500-599files_3|
  |sizes_1000-1999files_1|
  |sizes_1000-1999files_2|
  |sizes_1000-1999files_3|
  |sizes_2000-2999files_1|
  |sizes_2000-2999files_2|
  |sizes_2000-2999files_3|
  |sizes_3000-3999files_1|
  |sizes_3000-3999files_2|
  |sizes_3000-3999files_3|
  |sizes_4000-4999files_1|
  |sizes_4000-4999files_2|
  |sizes_4000-4999files_3|
  |sizes_5000-5999files_1|
  |sizes_5000-5999files_2|
