Feature: Packages that should ingest correctly under DAITSS 2

  Scenario Outline: The submission and ingest of a package with a copy of itself inside itself
    Given I goto "/submit"
    When I specifically select a <package> sip to upload
    And I press "Submit"
    And I click on "ingesting"
    And I choose "start"
    And I press "Update"
    And I wait for it to finish
      Examples:

      |package|
      |35 content files|
      |1000 content files|
      |10000 content files|
      |duplicate content files by checksum|
      |empty content file|
      |content not described|
      |copy of descriptor|
      |ISSN Entity ID|
      |OJBID different than package name|
      |no checksums for content files|
      |package name different than ID in metsHDr|
      |mdRef element in descriptive metadata|
      |empty lower directory not listed|
      |more than one lower level directory|
      |descriptor in lower directory|

