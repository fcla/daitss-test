Given /^an empty workspace$/ do
  empty_out_workspace
end

Given /^a workspace$/ do
  Given "an empty workspace"
end

Given /^a workspace with (\d+) (\w*) ?wips?$/ do |count, state|
  Given "a workspace"
  And "it has #{count} #{state} wips"
end

Given /^it has (\d+) (running|idle|snafu|stopped|) ?wips?$/ do |count, state|
  Given "it contains #{count} good #{state} wips"
end

Given /^it contains (\d+) (\w+) (running|idle|snafu|stopped|) ?wips?$/ do |count, package, state|

  case package
  when 'good'
    package = 'haskell-nums-pdf.zip'
  when 'virus'
    package = 'ateam-virus.zip'
  end

  count.to_i.times do

    wip = submit package

    case state
    when 'idle', ""
    when 'snafu'

      begin
        raise "oops this is not a real error!"
      rescue => e
        wip.snafu = e
      end

    when 'stopped'
      wip.start
      wip.stop

    when 'running'
      wip.start

    end

  end

end

Given /^a workspace with the following wips:$/ do |table|
  Given "a workspace"

  table.hashes.each do |h|
    count = h['count']
    state = h['state']
    And "it has #{count} #{state} wips"
  end

end

When /^all running wips have finished$/ do
  while true
    visit "/workspace"
    last_response.should be_ok
    doc = Nokogiri::HTML last_response.body

    if (doc / "td:contains('running')").size == 0
      break
    end
    sleep 0.5
  end
end

Then /^there should be (\d+) (running|idle|snafu|stopped|) ?wips?$/ do |count, state|
  last_response.should be_ok
  doc = Nokogiri::HTML last_response.body

  unless state.empty?
    (doc / "td:contains('#{state}')").size.should == count.to_i
  else
    (doc / "tr td:first-child").size.should == count.to_i
  end

end

Then /^there should be the following wips:$/ do |table|

  table.hashes.each do |h|
    count = h['count']
    state = h['state']
    Then "there should be #{count} #{state} wips"
  end

end

When /^I select "([^\"]*)"$/ do |bin|
  select bin, :from => 'stash-bin'
end
