require 'daitss/db/ops'
require 'daitss/db/ops/aip'
require 'daitss/db/fast'
require 'daitss/config'
require 'fileutils'
require 'daitss/proc/workspace'

# setup config
Daitss::CONFIG.load_from_env
DataMapper.setup :default, Daitss::CONFIG['database-url']

REPO_ROOT = File.join File.dirname(__FILE__), '..', '..'
SIP_DIRS = [File.join(REPO_ROOT, "sips"), ENV["AUX_SIP_PATH"]]
SERVICES_DIR = File.join(File.dirname(ENV["CONFIG"]), "service")

SUBMISSION_CLIENT_PATH = File.join SERVICES_DIR, "submission", "submit-filesystem.rb"
INGEST_BIN_PATH = "dbin ingest"
DISPATCH_WORKSPACE_BIN_PATH = File.join SERVICES_DIR, "request", "dispatch-workspace.rb"

WORKSPACE = Workspace.new(Daitss::CONFIG['workspace']).path

def run_submit package, expect_success = true, username = @username, password = @password
  raise "No users created" unless @username and @password

  sip_path = find_package package

  output = `#{SUBMISSION_CLIENT_PATH} --url #{Daitss::CONFIG['submission']} --package #{sip_path} --name #{package} --username #{username} --password #{password}`
  raise "Submission seems to have failed: #{output}" if ($?.exitstatus != 0 and expect_success == true)

  return output.chomp
end

def run_ingest ieid, expect_success = true
  raise "No IEID to ingest" unless ieid

  output = `#{INGEST_BIN_PATH} #{ieid}`
  raise "Ingest seems to have failed: #{output}" if ($?.exitstatus != 0 and expect_success == true)
end

def setup_workspace
  FileUtils.rm_rf Dir.glob("#{WORKSPACE}/*")
end

def delete_wip ieid
  FileUtils.rm_rf File.join(WORKSPACE, ieid)
end

def submit_request ieid, request_type, expect_success = true, username = @username, password = @password
  case request_type
  when "dissemination"
    @req_type = "disseminate"
  when "withdrawal"
    @req_type = "withdraw"
  when "peek"
    @req_type = "peek"
  else
    raise "Invalid request type: #{request_type}"
  end

  url = "#{Daitss::CONFIG['request']}/requests/#{ieid}/#{@req_type}"
  output = `curl -v -X POST #{url} -u #{username}:#{password} 2>&1`

  raise "Request submission seems to have failed: #{output}" if (not output =~ /201 Created/ and expect_success == true)

  return output
end

def delete_request ieid, request_type, expect_success = true, username = @username, password = @password
  case request_type
  when "dissemination"
    @req_type = "disseminate"
  when "withdrawal"
    @req_type = "withdraw"
  when "peek"
    @req_type = "peek"
  else
    raise "Invalid request type: #{request_type}"
  end

  url = "#{Daitss::CONFIG['request']}/requests/#{ieid}/#{@req_type}"
  output = `curl -v -X DELETE #{url} -u #{username}:#{password} 2>&1`

  raise "Request deletion seems to have failed: #{output}" if (not output =~ /200 OK/ and expect_success == true)

  return output
end

def create_aux_operator
  if not OperationsAgent.first(:identifier => "op")
    a = Account.get(1)
    add_operator a, "op", "op"
  end

  return "op"
end

def query_request ieid, request_type 
  create_aux_operator

  url = "#{Daitss::CONFIG['request']}/requests/#{ieid}/#{@req_type}"
  `curl -v #{url} -u op:op 2>&1`
end

def dispatch_workspace
  `#{DISPATCH_WORKSPACE_BIN_PATH}`
  raise "Non-zero exit status running dispatch-workspace.rb" unless $?.exitstatus == 0
end

# authorizes a withdrawal request for @ieid. Raises error if no withdrawal request to authorize exists
def authorize_request use_aux_operator = true
  if use_aux_operator
    create_aux_operator
    user = "op"
    pass = "op"
  else
    user = @username
    pass = @password
  end

  url = "#{Daitss::CONFIG['request']}/requests/#{@ieid}/withdraw/approve"
  `curl -v -X POST #{url} -u #{user}:#{pass} 2>&1`
end

# looks in all possible SIP_PATHS to see if package exists. Raises error if package not found, 
# otherwise returns path to package

def find_package package
  
  SIP_DIRS.each do |sip_dir|
    next unless sip_dir

    if File.exists? File.join sip_dir, package
      return File.join sip_dir, package
    end
  end

  raise "Package #{package} not found on disk"
end

# GIVEN

Given /^an archive (.*)$/ do |actor|

  a = Account.first(:code => "ACT")

  case actor

  when "operator"
    @username = "operator"
    @password = "operator"

  when "contact"
    add_contact a

    @username = "contact"
    @password = "contact"

  when "invalid user"
    @username = "foo"
    @password = "bar"

  when "unauthorized contact"
    add_contact a, []

    @username = "contact"
    @password = "contact"

  when "contact from a different account"
    a = add_account "FOO", "FOO"

    add_contact a, "foo", "foo"

    @username = "foo"
    @password = "foo"
  end
end

Given /^a workspace$/ do
  setup_workspace
end

# ingests a package with an operator
Given /^a good package that has been ingested$/ do
  id = create_aux_operator
  @ieid = run_submit "ateam", true, id, id
  run_ingest @ieid
  delete_wip @ieid
  add_intentity @ieid 
end


Given /^(a|an) (.*) package$/ do |n, package|
  case package

  when "good"
    @package = "ateam"

  when "empty"
    @package = "ateam-missing-contentfile"

  when "checksum mismatch"
    @package = "ateam-checksum-mismatch"

  when "bad project"
    @package = "ateam-bad-project"

  when "bad account"
    @package = "ateam-bad-account"

  when "descriptor missing"
    @package = "ateam-descriptor-missing"

  when "descriptor not well formed"
    @package = "ateam-descriptor-broken"

  when "descriptor invalid"
    @package = "ateam-descriptor-invalid"

  when "package in package"
    @package = "ateam-package-within"

  when "35 content files"
    @package = "35-content-files"
   
  when "1000 content files"
    @package = "1000-content-files"

  when "duplicate content files by checksum"
    @package = "duplicate-files-checksum"

  when "empty content file"
    @package = "FDAD27coa_empty_content"
	
  when "content not described"
    @package = "FDAD27cob_not_described"
	
  when "copy of descriptor"
    @package = "FDAD27dea_copy"
	
  when "ISSN Entity ID"
    @package = "FDAD27deb_ISSN_Entity"
	
  when "OJBID different than package name"
    @package = "FDAD27dec_OBJID_package"
	
  when "no checksums for content files"
    @package = "FDAD27ded_no_checksums"
	
  when "package name different than ID in metsHDr"
    @package = "FDAD27def_Hdr_ID"
	
  when "mdRef element in descriptive metadata"
    @package = "FDAD27deg_mdRef"
	
  when "empty lower directory not listed"
    @package = "FDAD27dib_empty_not_listed"
	
  when "more than one lower level directory"
    @package = "FDAD27did_multiple_lower"
	
  when "descriptor in lower directory"
    @package = "FDAD25deb_descriptor_lower"
	
  when "missing account attribute"
    @package = "FDAD25ded_missing_account"
	
  when "missing project attribute"
    @package = "FDAD25ded_missing_project"
	
  when "mxf descriptor"
    @package = "FDAD25def_MXF"	
	
  when "toc descriptor"
    @package = "FDAD25deg_TOC"	
	
  when "empty account attribute"
    @package = "FDAD25del_account_name"
	
  when "empty project attribute"
    @package = "FDAD25del_project_name"
	
  when "descriptor present but named incorrectly"
    @package = "FDAD25dei_wrong_name"
	
  when "no DAITSS agreement"
    @package = "FDAD25dej_no_agreement"
	
  when "two DAITSS agreements"
    @package = "FDAD25dek_two_agreements"
	
  when "content in lower directory than listed"
    @package = "FDAD25coc_lower_directory"
	
  when "empty directory"
    @package = "FDAD25ota_empty_directory"
	
  when "name with more than 32 characters"
    @package = "FDAD25otb_more_than_32_characters_name"
	
  when "described hidden file"
    @package = "FDAD25otc_described_hidden"
	
  when "undescribed hidden file"
    @package = "FDAD25otd_undescribed_hidden"
	
  when "content files with special characters"
    @package = "FDAD25ote_special_character"
	
  when "lower level content files with special characters"
    @package = "FDAD25otf_character_lower"
	
  when "only a descriptor file"
    @package = "FDAD25otg_not_directory_d"
	
  when "only a content file"
    @package = "FDAD25otg_not_directory_c"
	
  when "more than one validation problem"
    @package = "FDAD25oth_multiple_errors"
	
  when "special character in directory name"
    @package = "FDAD25oti_special_character"
	
  when "wave"
    @package = "wave"

  when "etd"
    @package = "etd"

  when "haskell-nums-pdf"
    @package = "haskell-nums-pdf"

  when "jpeg"
    @package = "jpeg"

  when "jpeg2000"
    @package = "jpeg2000"

  when "geotiff"
    @package = "geotiff"

  when "protectedpdf"
    @package = "protectedpdf"

  when "ateam"
    @package = "ateam"
	
  when "ateam-brokenlink"
    @package = "ateam-brokenlink"
  
  when "Word Document"
    @package = "FDAD2_doc"
	
  when "JPEG2000"
    @package = "FDAD2_jp2"
	
  when "JPG"
    @package = "FDAD2_jpg"
	
  when "Database"
    @package = "FDAD2_mdb"
	
  when "MPG"
    @package = "FDAD2_mpg"
	
  when "PDF 1.3"
    @package = "FDAD2_pdf_13"
  
  when "PDF 1.4"
    @package = "FDAD2_pdf_14"
	
  when "PDF 1.5"
    @package = "FDAD2_pdf_15"
	
  when "PDF 1.6"
    @package = "FDAD2_pdf_16"
	
  when "PNG"
    @package = "FDAD2_png"
	
  when "PPT"
    @package = "FDAD2_ppt"
	
  when "TIFF 4"
    @package = "FDAD2_tif_4"
	
  when "TIFF 5"
    @package = "FDAD2_tif_5"
	 
  when "TIFF 6"
    @package = "FDAD2_tif_6"
	
  when "WAV"
    @package = "FDAD2_wav"
	
  when "XML"
    @package = "FDAD2_xml_mets"

  when "sizes_under_10files_1"
    @package = "UF00001634_00001"
	
  when "sizes_under_10files_2"
    @package = "UF00091363_00005"

  when "sizes_under_10files_3"
    @package = "UF00001634_00001"

  when "sizes_10-19files_1"
    @package = "UF00094886_00005"

  when "sizes_10-19files_2"
    @package = "UF00087344_00020"

  when "sizes_10-19files_3"
    @package = "UF00017997_00001"

  when "sizes_20-29files_1"
    @package = "UF00000081_16435"

  when "sizes_20-29files_2"
    @package = "UF00091263_00198"

  when "sizes_20-29files_3"
    @package = "WL00003184_00001"

  when "sizes_30-39files_1"
    @package = "UF00028298_02187"

  when "sizes_30-39files_2"
    @package = "UF00048742_00294"

  when "sizes_30-39files_3"
    @package = "UF00075814_00002"

  when "sizes_40-49files_1"
    @package = "UF00000081_09740"

  when "sizes_40-49files_2"
    @package = "UF00072699_00708"

  when "sizes_40-49files_3"
    @package = "UF00073688_00252"

  when "sizes_50-59files_1"
    @package = "UF00028298_00057"

  when "sizes_50-59files_2"
    @package = "UF00079945_00073"

  when "sizes_50-59files_3"
    @package = "UF00087294_00560"

  when "sizes_60-69files_1"
    @package = "AM00000242_00051"

  when "sizes_60-69files_2"
    @package = "UF00067675_00001"

  when "sizes_60-69files_3"
    @package = "UF00075924_00033"

  when "sizes_70-79files_1"
    @package = "UF00055105_00001"

  when "sizes_70-79files_2"
    @package = "UF00075911_00696"

  when "sizes_70-79files_3"
    @package = "UF00085924_00001"

  when "sizes_80-89files_1"
    @package = "SF00000129"

  when "sizes_80-89files_2"
    @package = "UF00079944_00289"

  when "sizes_80-89files_3"
    @package = "UF00100262_00001"

  when "sizes_90-99files_1"
    @package = "UF00014569_00001"

  when "sizes_90-99files_2"
    @package = "UF00027604_00018"

  when "sizes_90-99files_3"
    @package = "UF00028419_02887"

  when "sizes_100-199files_1"
    @package = "UF00001024_00001"

  when "sizes_100-199files_2"
    @package = "UF00001565_02560"

  when "sizes_100-199files_3"
    @package = "UF00075911_00161"

  when "sizes_200-299files_1"
    @package = "AM00000319_00011"

  when "sizes_200-299files_2"
    @package = "UF00023252_00001"

  when "sizes_200-299files_3"
    @package = "UF00084249_00002"

  when "sizes_300-399files_1"
    @package = "UF00001565_01520"

  when "sizes_300-399files_2"
    @package = "UF00028296_00204"

  when "sizes_300-399files_3"
    @package = "UF00071726_00010"

  when "sizes_400-499files_1"
    @package = "UF00014989_00001"

  when "sizes_400-499files_2"
    @package = "UF00076217_00029"

  when "sizes_400-499files_3"
    @package = "UF00080613_00004"

  when "sizes_500-599files_1"
    @package = "UF00000445_00001"

  when "sizes_500-599files_2"
    @package = "UF00075939_00006"

  when "sizes_500-599files_3"
    @package = "UF00075961_00001"

  when "sizes_1000-1999files_1"
    @package = "UF00016653_00001"

  when "sizes_1000-1999files_2"
    @package = "UF00085531_00001"

  when "sizes_1000-1999files_3"
    @package = "UF00099515_00001"

  when "sizes_2000-2999files_1"
    @package = "UF00001997_00001"

  when "sizes_2000-2999files_2"
    @package = "UF00055632_00001"

  when "sizes_2000-2999files_3"
    @package = "UF00073382_00001"

  when "sizes_3000-3999files_1"
    @package = "UF00074933_00001"

  when "sizes_3000-3999files_2"
    @package = "UF00089237_00001"

  when "sizes_3000-3999files_3"
    @package = "UF00094187_00002"

  when "sizes_4000-4999files_1"
    @package = "UF00015454_00037"

  when "sizes_4000-4999files_2"
    @package = "UF00067435_00001"

  when "sizes_4000-4999files_3"
    @package = "UF00073608_00001"

  when "sizes_5000-5999files_1"
    @package = "UF00023701_00002"

  when "sizes_5000-5999files_2"
    @package = "UF00053733_00004"

	else
     pending "No definition for #{package} package"

  end
end 

# WHEN

When /^ingest is (run|attempted) on that package$/ do |expectation|
  case expectation

  when "run"
    run_ingest @ieid

  when "attempted"
    run_ingest @ieid, false
  end
end

When /^submission is (run|attempted) on that package$/ do |expectation|
  case expectation

  when "run"
    @ieid = run_submit @package

  when "attempted"
    @submission_output = run_submit @package, false

    # sometimes there is an IEID in the curl output. If so, save it.
    if @submission_output.split("* Closing connection #0\n")[1]
      @ieid = @submission_output.split("* Closing connection #0\n")[1].split(":")[0]
    else
      @ieid = nil
    end
  end
end

When /^a (dissemination|withdrawal|peek) request is (submitted|attempted|deleted) for that aip$/ do |req_type, expectation|
  case expectation

  when "submitted"
    @request_output = submit_request @ieid, req_type
  when "attempted"
    @request_output = submit_request @ieid, req_type, false
  when "deleted"
    @request_output = delete_request @ieid, req_type
  end
end

When /^the workspace is polled$/ do
  dispatch_workspace
end

When /^that request is authorized by (.*)$/ do |actor|

  case actor

  when "another operator"
    @authorization_output = authorize_request

  when "the request submitter"
    @authorization_output = authorize_request false
  end
end

### THEN

Then /^the package is present in the AIP store once$/ do
  rows = Aip.all

  raise "More than one record found in AIP store" unless rows.length == 1
end

Then /^the package is present in the aip store$/ do
  Aip.get!(@ieid)
end

Then /^there (is|is not) an operations event for the (.*)$/ do |expectation, event_type|
  sip = SubmittedSip.first(:ieid => @ieid)

  case event_type

  when "submission"
    event = sip.operations_events.first(:event_name => "Package Submission")

  when "ingest"
    pending "ingest doesn't yet add an op event for ingest"

  when "reject"
    pending "ingest doesn't yet add an op event for reject"

  when "dissemination request queuing", "withdrawal request queuing", "peek request queuing"
    event = sip.operations_events.first(:event_name => "Request Submission")
    raise "Operations event does not reflect correct request type" unless event.notes =~ /#{@req_type}/

  when "dissemination request dequeuing", "withdrawal request dequeuing", "peek request dequeuing"
    event = sip.operations_events.first(:event_name => "Request Released To Workspace")

  when "dissemination request deletion", "withdrawal request deletion", "peek request deletion"
    event = sip.operations_events.first(:event_name => "Request Deletion")

  when "withdrawal request authorization"
    event = sip.operations_events.first(:event_name => "Request Approval")

  else
    pending "Step not yet implemented"

  end

  if expectation == "is"
    raise "No #{event_type} ops event found" unless event
  else
    raise "#{event_type} ops event found" if event
  end

end

Then /^the package is rejected$/ do
  tag_file_path = File.join WORKSPACE, @ieid, "tags", "reject"

  raise "Package not rejected" unless File.exists? tag_file_path
end

Then /^submission fails$/ do
  raise "Submission appears to have succeeded: #{@submission_output}" unless @submission_output =~ /HTTP\/1.1 4[\d]{2}/
end

Then /^the request is (queued|denied|not queued|not authorized)$/ do |status|
  case status

  when "queued"
    raise "Request not queued" if (query_request @ieid, @req_type) =~ /HTTP\.1.1 404/
  when "not queued"
    raise "Request queued" unless (query_request @ieid, @req_type) =~ /HTTP\/1.1 404/
  when "denied"
    raise "Request not denied" unless @request_output =~ /HTTP\/1.1 4[\d]{2}/
  when "not authorized"
    #puts query_request @ieid, @req_type
    raise "Request authorized" unless (query_request @ieid, @req_type) =~ /authorized="false"/
  end
end

Then /^there (is|is not) a (dissemination|withdrawal|peek|ingest) wip in the workspace$/ do |expectation, req_type|
  if expectation == "is"
    raise "Wip for #{@ieid} not in workspace" unless File.directory?(File.join(WORKSPACE, @ieid))

    if ["dissemination", "withdrawal", "peek"].include? req_type
      raise "Missing #{req_type} tag file" unless File.file?(File.join(WORKSPACE, @ieid, "tags", "#{req_type}-request")) 

      if req_type == "dissemination"
        raise "Missing drop path tag file" unless File.file?(File.join(WORKSPACE, @ieid, "tags", "drop-path")) 
      end
    elsif req_type == "ingest"
      raise "Missing #{req_type} tag file" unless File.file?(File.join(WORKSPACE, @ieid, "tags", "task")) 
      raise "Wrong task in wip" unless File.read(File.join(WORKSPACE, @ieid, "tags", "task")) == "ingest" 
    end

  else
    raise "Wip for #{@ieid} is in workspace" if File.directory?(File.join(WORKSPACE, @ieid))
  end
end

Then /^there is a record in the ops sip table for the package$/ do
  raise "No record for sip found for IEID #{@ieid}" unless SubmittedSip.first(:ieid => @ieid)
end

Then /^submitted sips table shows package name (.*), number of files (.*), and package size (.*)$/ do |name, number_of_files, package_size|
  sip = SubmittedSip.first(:ieid => @ieid)

  raise "package name in submitted sip table (#{sip.package_name}) doesn't match #{name}" unless sip.package_name == name
  raise "number of files in submitted sip table (#{sip.number_of_datafiles}) doesn't match #{number_of_files}" unless sip.number_of_datafiles == number_of_files.to_i
  raise "package size in submitted sip table (#{sip.package_size}) doesn't match #{package_size}" unless sip.package_size == package_size.to_i
end

Then /^the submission operations event denotes reject and shows details for a (.*)$/ do |notes_field_snippet|
  event = OperationsEvent.first(:submitted_sip => {:ieid => @ieid}, :event_name => "Package Submission")

  raise "No op event found" unless event
  raise "Op event doesn't denote failure" unless event.notes =~ /outcome: reject/
  raise "Op event doesn't show expected detail: expected string '#{notes_field_snippet}', found: '#{event.notes}'" unless event.notes =~ /#{notes_field_snippet}/
end

Then /^there is not a wip in the workspace$/ do
  raise "Wip found in workspace for IEID #{@ieid}" if File.directory? File.join(WORKSPACE.path, @ieid)
end

Then /^the ingest time is output$/ do
  sip = SubmittedSip.first(:ieid => @ieid)

  start_event = OperationsEvent.first(:submitted_sip => sip, :event_name => "ingest started")
  stop_event = OperationsEvent.first(:submitted_sip => sip, :event_name => "ingest finished")

  start_time = Time.parse(start_event.timestamp.to_s)
  stop_time = Time.parse(stop_event.timestamp.to_s)

  puts "@@@ Ingest elapsed time for package #{@package}: " + (stop_time - start_time).to_s
end

