Given(/^I am on the home page$/) do
  visit "/"
end

Given(/^I go to "(.*?)"$/) do |the_link|
  click_link the_link
end

When(/^I fill in "(.*?)" with "(.*?)"$/) do |input, value|
  fill_in input, with: value
end

When(/^I press "(.*?)"$/) do |the_button|
  click_button the_button
end

Then(/^I should see "(.*?)"$/) do |task|
  assert page.has_content?(task)
end

# invalid post
Then(/^I should be told "(.*?)"$/) do |error_message|
  assert page.has_content?(error_message)
end

# mark as complete

Given(/^I have the following tasks:$/) do |table|
  # table is a Cucumber::Ast::Table
  for hash in table.hashes
    Task.create(hash)
  end
end

When(/^I follow "(.*?)" associated with "(.*?)"$/) do |arg1, arg2|
  first('li').click_link('Edit')
end

When(/^I check the "(.*?)" checkbox$/) do |arg1|
  page.find('input[type=checkbox]').set(true)
end

Then(/^I should see "(.*?)" as completed\.$/) do |task|
  assert first('li').parent.has_css?('.completed')
end

# delete a task

When(/^I click on the "(.*?)" next to "(.*?)"$/) do |arg1, arg2|
  first('li').click_link('Delete')
end

Then(/^I should no longer see "(.*?)"$/) do |task|
  assert page.has_no_content?(task)
end
