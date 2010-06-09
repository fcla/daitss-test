require 'db/operations_agents'
require 'db/operations_events'
require 'db/sip'
require 'aip'
require 'daitss/config'
require 'fileutils'
require 'workspace'

# setup config
Daitss::CONFIG.load_from_env
DataMapper.setup :default, Daitss::CONFIG['database-url']

REPO_ROOT = File.join File.dirname(__FILE__), '..', '..'
SIP_DIR = File.join REPO_ROOT, "sips"
SERVICES_DIR = File.join(File.dirname(ENV["CONFIG"]), "service")

SUBMISSION_CLIENT_PATH = File.join SERVICES_DIR, "submission", "submit-filesystem.rb"
INGEST_BIN_PATH = "ingest"
DISPATCH_WORKSPACE_BIN_PATH = File.join SERVICES_DIR, "request", "dispatch-workspace.rb"

WORKSPACE = Workspace.new(Daitss::CONFIG['workspace']).path


def run_submit package, expect_success = true, username = @username, password = @password
  raise "No users created" unless @username and @password

  sip_path = File.join SIP_DIR, package
  raise "Specified SIP not found" unless File.directory? sip_path

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

