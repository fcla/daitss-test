Then /^the ingest time is output$/ do
  start_event = Event.first(:name => "ingest started")
  finish_event = Event.first(:name => "ingest finished")

  start_time = Time.parse start_event.timestamp.to_s
  finish_time = Time.parse finish_event.timestamp.to_s

  puts "*** Ingest time: " + (finish_time - start_time).to_s
end
