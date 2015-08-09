Given(/^I am on the mission index$/) do
  visit "/missions"
end

When(/^I click add mission$/) do
  page.click_link "Add mission"
end

When(/^I view a mission$/) do
  @mission = Mission.first
  visit "/missions/#{@mission.id}"
end

Then(/^I see that mission$/) do
  expect(page).to have_content(@mission.name)
end

Then(/^I can create a new mission$/) do
  page.find("#mission-name").set("An awesome mission")
  page.find("#mission-description").set("An awesome description")
  page.click_button("Save")
end

Then(/^I can see that mission$/) do
  expect(page).to have_content "Add mission"
  expect(page).to have_content "An awesome mission"
  expect(page).to have_content "An awesome description"

  expect(current_url).to match(/missions$/)
end
