Feature: FDA submission test packages
  Scenario Outline: packages that should submit successfully 
    Given I goto "/submit"
    When I specifically select a <package> sip to upload
    And I press "Submit"
    Then I should be at a package page
    And in the events I should see a submission event
    Examples:

    |package|
    |content not described|
    |copy of descriptor|
    |objid different than package name|
    |no checksums|
    |package name different than metsHdr|
    |mdRef in descriptive metadata|
    |empty lower dir not listed|
    |more than one lower level dir|
    |marc metadata|
    |marc/mods metadata|
