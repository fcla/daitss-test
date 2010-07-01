Feature: A submission and subsequent ingest operation of a known good package
  should result in a successful ingest. 

  Scenario Outline: A submission and ingest of a known good package by an operator
    Given an archive operator
    And a workspace
    And a <package> package
    When submission is run on that package
    And ingest is run on that package
    Then the package is present in the aip store
    And there is an operations event for the submission
    And there is an operations event for the ingest
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

