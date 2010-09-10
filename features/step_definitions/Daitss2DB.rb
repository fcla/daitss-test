require 'xml'

abs = File.join File.dirname(__FILE__), '..'

Then /^I should see (.+?) intentitiy record$/ do |ieid|
  intentity = Intentity.get(ieid)
  intentity.should_not be_nil
end

Then /^all (.+) representations should exist/ do |ieid|
  # check for representation-0, representation-current
  r0 = Datafile.first(:intentity_id => ieid, :r0.like  => '%representation/original')
  r0.should_not be_nil
  rc = Datafile.first(:intentity_id => ieid, :rc.like  => '%representation/current')
  rc.should_not be_nil
end

Then /^I should have a datafile named (.+)/ do |filename|
  df = Datafile.first(:original_path => filename)
  df.should_not be_nil
  @dfid = df.id
end

Then /^I should have not a datafile named (.+)/ do |filename|
  df = Datafile.first(:original_path => filename)
  df.should be_nil
end

Then /^I should have a document with embedded fonts$/ do
  document = Document.first(:datafile_id => @dfid)
  document.should_not be_nil
  fonts = Font.all(:document_id => document.id)
  fonts.each {|font| font.embedded.should == true}
end

Then /^I should have (.+) image bitstreams$/ do |numOfBitstreams|
  count = Bitstream.count(:datafile_id => @dfid)
  count.should == numOfBitstreams.to_i
end

Then /^the datafile should be associated an audio stream$/ do
  audio = Audio.first(:datafile_id => @dfid)
  audio.should_not be_nil
end


Then /^the datafile should be associated an image stream$/ do
  image = Image.first(:datafile_id => @dfid)
  image.should_not be_nil
end

Then /^there should be an image for bitstream in the datafile$/ do
  bitstream = Bitstream.first(:datafile_id => @dfid)
  image = Image.first(:bitstream_id => bitstream.id)
  image.should_not be_nil
end

Then /^the datafile should be associated a text stream$/ do
  text = Text.first(:datafile_id => @dfid)
  text.should_not be_nil
end

Then /^there is an (.+) event for the intentity$/ do |eventType|
  intentity = Intentity.first()
  event = PreservationEvent.first(:relatedObjectId => intentity.id, :e_type => eventType)
  event.should_not be_nil
end

Then /^the datafile should be associated with a (.+) event$/ do |eventType|
  event = PreservationEvent.first(:relatedObjectId => @dfid, :e_type => eventType)
  event.should_not be_nil
end

Then /^there is a (.+) checksum for the datafile$/ do |mdType|
  event = MessageDigest.first(:datafile_id => @dfid, :code => mdType)
  event.should_not be_nil
end

Then /^there should be a normalization relationship links to normalized file$/ do
  relationship = Relationship.first(:object1 => @dfid, :type => "normalized to")
  relationship.should_not be_nil
  @norm_fileid = relationship.object2
end

Then /^the normalized file should be associated with an audio stream$/ do
  audio = Audio.first(:datafile_id => @norm_fileid)
  audio.should_not be_nil
end

Then /^the normalized file should have archive as origin$/ do
 df = Datafile.first(:id => @norm_fileid)
 df.origin.should == "ARCHIVE"
end

Then /^the original file should have depositor as origin$/ do
  df = Datafile.first(:id => @dfid)
  df.origin.should == "DEPOSITOR"
end

Then /^it should have an inhibitor$/ do
  df = Datafile.first(:id => @dfid)
  found = false
  df.datafile_severe_element.each do |dfse|
    se = SevereElement.first(:id => dfse.severe_element_id)
    found = true if se.class == Inhibitor
  end
  found.should == true
end

Then /^it should have an anomaly$/ do
  df = Datafile.first(:id => @dfid)
  found = false
  df.datafile_severe_element.each do |dfse|
    se = SevereElement.first(:id => dfse.severe_element_id)
    found = true if se.class == Anomaly
  end
  found.should == true
end

Then /^it should have a broken link$/ do
  brokenLink = BrokenLink.first(:datafile_id => @dfid)
  brokenLink.should_not be_nil
end
