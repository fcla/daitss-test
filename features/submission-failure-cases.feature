Feature: Cases where packages fail to submit

  Scenario Outline: Submission failures which should result in a record in the sip table and an operations event
    Given an archive <user>
    And a workspace
    And a <package> package
    When submission is attempted on that package
    Then submission fails
	  And submitted sips table shows package name <package_name>, number of files <package_file>, and package size <package_size>
    And there is an operations event for the submission
	  And the submission operations event denotes reject and shows details for a <failure type>
	  And there is not a wip in the workspace
    Examples:
	
    |user|package|package_name|package_file|package_size|failure type|
    |operator|checksum mismatch|ateam-checksum-mismatch|2|923328|checksum mismatch|
    |operator|empty|ateam-missing-contentfile|1|1378|empty|
    |operator|bad project|ateam-bad-project|2|923342|bad project|
    |operator|bad account|ateam-bad-account|2|923342|bad account|
    |operator|descriptor not well formed|ateam-descriptor-broken|2|923331|descriptor not well formed|
    |operator|descriptor invalid|ateam-descriptor-invalid|2|923329|descriptor invalid|
    |operator|descriptor missing|ateam-descriptor-missing|1|921972|descriptor missing|
    |operator|descriptor in lower directory|FDAD25deb_descriptor_lower|3|3147|descriptor in lower directory|
    |operator|missing account attribute|FDAD25ded_missing_account|2|923323|missing account attribute|
    |operator|missing project attribute|FDAD25ded_missing_project|2|3307240|missing project attribute|
    |operator|empty account attribute|FDAD25del_account_name|2|923284|empty account attribute|
    |operator|empty project attribute|FDAD25del_project_name|2|923301|empty project attribute|
    |operator|descriptor present but named incorrectly|FDAD25dei_wrong_name|2|3135|descriptor present but named incorrectly|
    |operator|no DAITSS agreement|FDAD25dej_no_agreement|2|3306988|no DAITSS agreement|
    |operator|two DAITSS agreements|FDAD25dek_two_agreements|2|923449|two DAITSS agreements|
    |operator|content in lower directory than listed|FDAD25coc_lower_directory|3|4576373|content in lower directory than listed|
    |operator|empty directory|FDAD25ota_empty_directory|0|0|empty directory|
    |operator|name with more than 32 characters|FDAD25otb_more_than_32_characters_name|2|3307250|name with more than 32 characters|
    |operator|described hidden file|FDAD25otc_described_hidden|4|3260|described hidden file|
    |operator|undescribed hidden file|FDAD25otd_undescribed_hidden|4|3991|undescribed hidden file|
    |operator|content files with special characters|FDAD25ote_special_character|3|3156|content files with special characters|
    |operator|lower level content files with special characters|FDAD25otf_character_lower|3|4576426|lower level content files with special characters|
    |operator|only a descriptor file|FDAD25otg_not_directory_d|1|0|only a descriptor file|
    |operator|only a content file|FDAD25otg_not_directory_c|1|0|only a content file|
    |operator|more than one validation problem|FDAD25oth_multiple_errors|10|796339|more than one validation problem|
    |operator|toc descriptor|FDAD25deg_TOC|2|776676803|toc descriptor|


  Scenario Outline: Submission failures which should not result in a record in the sip table and an operations event
    Given an archive <user>
    And a workspace
    And a <package> package
    When submission is attempted on that package
    Then submission fails
    Examples:
    |user|package|
    |invalid user|good|
    |unauthorized contact|good|
