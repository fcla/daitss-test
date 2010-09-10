Given /^I submit (a|\d+) packages?$/ do |count|

  count = case count
          when 'a' then 1
          when /\d+/ then count.to_i
          else raise 'invalid count'
          end

  count.times { submit 'haskell-nums-pdf.zip' }
end

When /^I select a sip to upload$/ do
  When "I specifically select a good sip to upload"
end

When /^I specifically select a (.*) sip to upload$/ do |sip|

  case sip
  when "good"
    name = 'haskell-nums-pdf'
  when 'checksum mismatch'
    name = 'ateam-checksum-mismatch'
  when 'empty'
    name = 'ateam-missing-contentfile'
  when 'bad project'
    name = 'ateam-bad-project'
  when 'bad account'
    name = 'ateam-bad-account'
  when 'descriptor not well formed'
    name = 'ateam-descriptor-broken'
  when 'descriptor invalid'
    name = 'ateam-descriptor-invalid'
  when 'descriptor missing'
    name = 'ateam-descriptor-missing'
  when 'descriptor in lower directory'
    name = 'FDAD25deb_descriptor_lower'
  when 'missing account attribute'
    name = 'FDAD25ded_missing_account'
  when 'empty account attribute'
    name = 'FDAD25del_account_name'
  when 'missing project attribute'
    name = 'FDAD25ded_missing_project'
  when 'empty project attribute'
    name = 'FDAD25del_project_name'
  when 'descriptor named incorrectly'
    name = 'FDAD25dei_wrong_name'
  when 'no DAITSS agreement'
    name = 'FDAD25dej_no_agreement'
  when 'two DAITSS agreements'
    name = 'FDAD25dek_two_agreements'
  when 'content in lower directory'
    name = 'FDAD25coc_lower_directory'
  when 'empty directory'
    name = 'FDAD25ota_empty_directory'
  when 'name has more than 32 chars'
    name = 'FDAD25otb_more_than_32_characters_name'
  when 'described hidden file'
    name = 'FDAD25otc_described_hidden'
  when 'undescribed hidden file'
    name = 'FDAD25otd_undescribed_hidden'
  when 'special characters'
    name = 'FDAD25ote_special_character'
  when 'lower level special characters'
    name = 'FDAD25otf_character_lower'
  when 'content not described'
    name = 'FDAD27cob_not_described'
  when 'copy of descriptor'
    name = 'FDAD27dea_copy'
  when 'objid different than package name'
    name = 'FDAD27dec_OBJID_package'
  when 'no checksums'
    name = 'FDAD27ded_no_checksums'
  when 'package name different than metsHdr'
    name = 'FDAD27def_Hdr_ID'
  when 'mdRef in descriptive metadata'
    name = 'FDAD27deg_mdRef'
  when 'empty lower dir not listed'
    name = 'FDAD27dib_empty_not_listed'
  when 'more than one lower level dir'
    name = 'FDAD27did_multiple_lower'
  when 'marc metadata'
    name = 'FDAD26dma_marc'
  when 'marc/mods metadata'
    name = 'FDAD26dmd_marc_mods'
  when 'ateam'
    name = 'ateam'
  when 'wave'
     name = 'wave'
  when 'etd'
    name = 'etd'
  when 'jpeg'
    name = 'jpeg'
  when 'jpeg2000'
    name = 'jpeg2000'
  when 'geotiff'
    name = 'geotiff'
  when 'obsolete'
    pending "not yet implemented"
  when 'ateam-brokenlink'
    name = 'ateam-brokenlink'
  when 'protectedpdf'
    name = 'protectedpdf'
 when 'Word Document'
    name = 'FDAD2_doc'
  when 'JPEG2000'
    name = 'FDAD2_jp2'
  when 'JPG'
    name = 'FDAD2_jpg'
  when 'Database'
    name = 'FDAD2_mdb'
  when 'MPG'
    name = 'FDAD2_mpg'
  when 'PDF 1.3'
    name = 'FDAD2_pdf_13'
  when 'PDF 1.4'
    name = 'FDAD2_pdf_14'
  when 'PDF 1.5'
    name = 'FDAD2_pdf_15'
  when 'PDF 1.6'
    name = 'FDAD2_pdf_16'
  when 'PNG'
    name = 'FDAD2_png'
  when 'PPT'
    name = 'FDAD2_ppt'
  when 'TIFF 4'
    name = 'FDAD2_tif_4'
  when 'TIFF 5'
    name = 'FDAD2_tif_5'
  when 'TIFF 6'
    name = 'FDAD2_tif_6'
  when 'WAV'
    name = 'FDAD2_wav'
  when 'XML'
    name = 'FDAD2_xml_mets'
    
  end

  sips << {:sip => name}
  tar = sip_tarball(name)
  dir = Dir.mktmpdir
  $cleanup << dir
  tar_file = File.join dir, "#{name}.tar"
  open(tar_file, 'w') { |o| o.write tar }
  attach_file 'sip', tar_file
end

Then /^I should be at a package page$/ do
  last_request.path.should =~ %r{/package/\w+}
end


