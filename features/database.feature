Feature: database population on various packages

Scenario: a good sip
	Given I goto "/submit"
  When I specifically select a ateam sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/ateam.xml
    And there is an submit event for the intentity
    And there is an ingest event for the intentity
	And the datafile should be associated with a describe event
	And the datafile should be associated with a virus check event
	And there is a SHA-1 checksum for the datafile
	And there is a MD5 checksum for the datafile
	
Scenario: an sip containing a wave file
	Given I goto "/submit"
  When I specifically select a wave sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/obj1.wav
	And the datafile should be associated an audio stream
	# And the datafile should be associated with a normalize event
	And there should be a normalization relationship links to normalized file
	And the normalized file should be associated with an audio stream
	And the normalized file should have archive as origin
	And the original file should have depositor as origin
	
Scenario: an sip containing a pdf with many images
	Given I goto "/submit"
  When I specifically select a etd sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/etd.pdf
 	And I should have 19 image bitstreams

Scenario: an sip containing a pdf with embedded fonts
	Given I goto "/submit"
  When I specifically select a good sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/Haskell98numbers.pdf
	And I should have a document with embedded fonts
	
Scenario: an sip containing a jpeg file
	Given I goto "/submit"
  When I specifically select a jpeg sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/DSC04975_small.jpg
	And the datafile should be associated an image stream

Scenario: an sip containing a jp2 file
	Given I goto "/submit"
  When I specifically select a jpeg2000 sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/WF00010502.jp2
	And there should be an image for bitstream in the datafile

Scenario: an sip containing a geotiff file
	Given I goto "/submit"
  When I specifically select a geotiff sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
 	Then I should have a datafile named sip-files/tjpeg.tif
 	And there should be an image for bitstream in the datafile	
	
Scenario: an sip containing a pdf with an anomaly and an inhibitor
	Given I goto "/submit"
  When I specifically select a protectedpdf sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/pwprotected.pdf
	And it should have an inhibitor
	And it should have an anomaly

Scenario: an sip containing a xml with broken links
	Given I goto "/submit"
  When I specifically select a ateam-brokenlink sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have a datafile named sip-files/UF00003061.xml
	And the datafile should be associated a text stream
	And it should have a broken link

Scenario: an sip containing a xml with an obsolete file
	Given I goto "/submit"
  When I specifically select a obsolete sip to upload
  And I press "Submit"
  And I goto "/workspace"
  And I choose "start"
  And I press "Update"
  And all running wips have finished 
	Then I should have not a datafile named 0-norm-0.wav

