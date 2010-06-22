Feature: Packages that should ingest correctly under DAITSS 2

  Scenario Outline: The submission and ingest of a package for description testing
    Given an archive operator
    And a workspace
    And a <package> package
    When submission is run on that package
    And ingest is run on that package
    Then there is a record of <format_name> format name for the file <original_file_name>
      Examples:

      |package|format_name|original_file_name|
      |Word Document|Microsoft Word for Windows Document|abstract.doc|
      |JPEG2000|JPEG2000|00021.jp2|
	  |JPG|JPEG File Interchange Format|DSC04975_small.jpg|
	  |Database|Microsoft Access Database|surveydata.mdb|
	  |MPG|MPEG-1 Video Format|jitter.mpg|
	  |PDF 1.3|Acrobat PDF 1.3 - Portable Document Format|etd.pdf|
	  |PDF 1.4|Acrobat PDF 1.4 - Portable Document Format|PdfGuideline.pdf|
	  |PDF 1.5|Acrobat PDF 1.5 - Portable Document Format|00001.pdf|
	  |PDF 1.6|Acrobat PDF 1.6 - Portable Document Format|Webb_Christina_M_200508_MA.pdf|
	  |PNG|Portable Network Graphics|daitss2.png|
	  |PPT|Microsoft Powerpoint Presentation|test.ppt|
	  |TIFF 4|Tagged Image File Format|florida.tif|
	  |TIFF 5|Tagged Image File Format|00170.tif|
	  |TIFF 6|Tagged Image File Format|tjpeg.tif|
	  |WAV|Waveform Audio|GLASS.WAV|
	  |XML|Extensible Markup Language|ateam.xml|