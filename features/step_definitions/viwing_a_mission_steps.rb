When(/^I view a mission$/) do
  @mission = Mission.first
  visit "/missions/#{@mission.id}"
end

Then(/^I see that mission$/) do
  expect(page).to have_content(@mission.name)
end
