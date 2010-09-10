Feature: A submission and subsequent ingest operation of a known good package
  should result in a successful ingest. 

  Scenario Outline: A submission and ingest of a known good package by an operator
    Given I goto "/submit"
    When I specifically select a <package> sip to upload
    And I press "Submit"
    And I goto "/workspace"
    And I choose "start"
    And I press "Update"
    And all running wips have finished 
    Then the package is present in the aip store
    And there should be 0 snafu wips
    And there should be 0 stopped wips
    Examples:
	    |package|
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
	    |MARC descriptive metadata|
	    |MARC/MODS descriptive metadata|

