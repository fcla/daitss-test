Feature: Cases where packages submit successfully

  Scenario: Submission of a good package by an operator
    Given an archive operator
    And a workspace
    And a <package> package
    When submission is run on that package
    Then there is an record in the submitted sips table
	And submitted sips tables shows package <package_name>
	And records <package_file> files
	And records <PRJ_ID> Project ID
    And records <package_size> for package size
    And there is an operations event for the submission
	And the operations event denotes success
	And there is a ingest wip in the workspace
    Examples:
	
    |package|package_name|package_file|PRJ_ID|package_size|
    |empty content file|FDAD27coa_empty_content|2|PRJ|1270|
    |content not described|FDAD27cob_not_described|10|PRJ|790753|
    |copy of descriptor|FDAD27dea_copy|11|PRJ|794752|
    |ISSN Entity ID|FDAD27deb_ISSN_Entity|2|PRJ|3307204|
    |OJBID different than package name|FDAD27dec_OBJID_package|2|PRJ|923336|
    |no checksums for content files|FDAD27ded_no_checksums|2|PRJ|3307170|
    |package name different than ID in metsHDr|FDAD27def_Hdr_ID|2|PRJ|3307200|
    |mdRef element in descriptive metadata|FDAD27deg_mdRef|2|PRJ|923104|
    |empty lower directory not listed|FDAD27dib_empty_not_listed|10|PRJ|791169|
    |more than one lower level directory|FDAD27did_multiple_lower|10|PRJ|791171|
    |MARC descriptive metadata|FDAD26dma_marc|
	|MARC/MODS descriptive metadata|FDAD26dmd_marc_mods|