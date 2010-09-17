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
  when "sizes_under_10files_1"
    name = "UF00001634_00001"
  when "sizes_under_10files_2"
    name = "UF00091363_00005"
  when "sizes_under_10files_3"
    name = "UF00001634_00001"
  when "sizes_10-19files_1"
    name = "UF00094886_00005"
  when "sizes_10-19files_2"
    name = "UF00087344_00020"
  when "sizes_10-19files_3"
    name = "UF00017997_00001"
  when "sizes_20-29files_1"
    name = "UF00000081_16435"
  when "sizes_20-29files_2"
    name = "UF00091263_00198"
  when "sizes_20-29files_3"
    name = "WL00003184_00001"
  when "sizes_30-39files_1"
    name = "UF00028298_02187"
  when "sizes_30-39files_2"
    name = "UF00048742_00294"
  when "sizes_30-39files_3"
    name = "UF00075814_00002"
  when "sizes_40-49files_1"
    name = "UF00000081_09740"
  when "sizes_40-49files_2"
    name = "UF00072699_00708"
  when "sizes_40-49files_3"
    name = "UF00073688_00252"
  when "sizes_50-59files_1"
    name = "UF00028298_00057"
  when "sizes_50-59files_2"
    name = "UF00079945_00073"
  when "sizes_50-59files_3"
    name = "UF00087294_00560"
  when "sizes_60-69files_1"
    name = "AM00000242_00051"
  when "sizes_60-69files_2"
    name = "UF00067675_00001"
  when "sizes_60-69files_3"
    name = "UF00075924_00033"
  when "sizes_70-79files_1"
    name = "UF00055105_00001"
  when "sizes_70-79files_2"
    name = "UF00075911_00696"
  when "sizes_70-79files_3"
    name = "UF00085924_00001"
  when "sizes_80-89files_1"
    name = "SF00000129"
  when "sizes_80-89files_2"
    name = "UF00079944_00289"
  when "sizes_80-89files_3"
    name = "UF00100262_00001"
  when "sizes_90-99files_1"
    name = "UF00014569_00001"
  when "sizes_90-99files_2"
    name = "UF00027604_00018"
  when "sizes_90-99files_3"
    name = "UF00028419_02887"
  when "sizes_100-199files_1"
    name = "UF00001024_00001"
  when "sizes_100-199files_2"
    name = "UF00001565_02560"
  when "sizes_100-199files_3"
    name = "UF00075911_00161"
  when "sizes_200-299files_1"
    name = "AM00000319_00011"
  when "sizes_200-299files_2"
    name = "UF00023252_00001"
  when "sizes_200-299files_3"
    name = "UF00084249_00002"
  when "sizes_300-399files_1"
    name = "UF00001565_01520"
  when "sizes_300-399files_2"
    name = "UF00028296_00204"
  when "sizes_300-399files_3"
    name = "UF00071726_00010"
  when "sizes_400-499files_1"
    name = "UF00014989_00001"
  when "sizes_400-499files_2"
    name = "UF00076217_00029"
  when "sizes_400-499files_3"
    name = "UF00080613_00004"
  when "sizes_500-599files_1"
    name = "UF00000445_00001"
  when "sizes_500-599files_2"
    name = "UF00075939_00006"
  when "sizes_500-599files_3"
    name = "UF00075961_00001"
  when "sizes_1000-1999files_1"
    name = "UF00016653_00001"
  when "sizes_1000-1999files_2"
    name = "UF00085531_00001"
  when "sizes_1000-1999files_3"
    name = "UF00099515_00001"
  when "sizes_2000-2999files_1"
    name = "UF00001997_00001"
  when "sizes_2000-2999files_2"
    name = "UF00055632_00001"
  when "sizes_2000-2999files_3"
    name = "UF00073382_00001"
  when "sizes_3000-3999files_1"
    name = "UF00074933_00001"
  when "sizes_3000-3999files_2"
    name = "UF00089237_00001"
  when "sizes_3000-3999files_3"
    name = "UF00094187_00002"
  when "sizes_4000-4999files_1"
    name = "UF00015454_00037"
  when "sizes_4000-4999files_2"
    name = "UF00067435_00001"
  when "sizes_4000-4999files_3"
    name = "UF00073608_00001"
  when "sizes_5000-5999files_1"
    name = "UF00023701_00002"
  when "sizes_5000-5999files_2"
    name = "UF00053733_00004"
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


