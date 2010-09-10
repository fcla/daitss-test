Given /^I fill in the user form with:$/ do |table|

  within "form#create-user" do

    table.hashes.each do |row|

      row.each do |field, value|
        fill_in field, :with => value
      end

    end

  end

end

Then /^there should be a user with:$/ do |table|

  table.hashes.each do |row|
    cell_conditions = row.values.map { |v| "td = '#{v}'"}.join ' and '
    last_response.should have_xpath("//tr[#{cell_conditions}]")
  end

end

Given /^a user "([^"]*)"$/ do |id|
  Given 'I goto "/admin"'

  within "form#create-user" do
    fill_in 'id', :with => id
    fill_in 'first_name', :with => "#{id} first name"
    fill_in 'last_name', :with => "#{id}last name"
    fill_in 'email', :with => "#{id}@example.com"
    fill_in 'phone', :with => "555 1212"
    fill_in 'address', :with => "San Jose"
  end

  When 'I press "Create User"'
  last_response.should be_ok
  @the_user = User.get id
  @the_user.should_not be_nil
end

Given /^that user (is|is not) empty$/ do |condition|
  if condition == 'is'
    @the_user.events.should be_empty
  else
    p = Package.new
    p.sip = Sip.new
    p.sip.name = 'FOO'
    p.sip.size_in_bytes = 10
    p.sip.number_of_datafiles = 10

    e = Event.new
    e.name = 'test event'
    e.timestamp = Time.now
    e.package = p

    @the_user.events << e
    @the_user.save.should be_true
  end
end

When /^I press "([^"]*)" for the user$/ do |button|

  within "tr:contains('#{@the_user.id}')" do
    click_button button
  end

end

Then /^there should not be a user "([^"]*)"$/ do |id|
  pending 'User.all is returning deleted records (paranoia gotcha)'
  last_response.should_not have_selector("td:contains('#{id}')")
end
