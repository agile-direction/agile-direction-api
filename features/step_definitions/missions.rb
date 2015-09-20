def new_mission
  Mission.new({
    name: Faker::Name.name,
    description: Faker::Lorem.sentence,
    public: true
  })
end

When(/^I create a mission/) do
  visit("/missions/new")
  @mission = new_mission
  fill_in("mission[name]", { with: @mission.name })
  fill_in("mission[description]", { with: @mission.description })
  click_button("Save")
end

When(/^I update a mission/) do
  @mission = new_mission
  @mission.save!
  visit("/missions/#{@mission.id}/edit")

  @mission.name = Faker::Name.name
  fill_in("mission[name]", { with: @mission.name })
  fill_in("mission[description]", { with: @mission.description })
  click_button("Save")
end

When(/^I have missions$/) do
  @missions = rand(1..rand(1..3)).times.collect do
    mission = new_mission
    mission.save!
    mission
  end
  visit "/missions"
end

Then(/^I should see missions/) do
  @missions.each do |mission|
    expect(page).to have_content(mission.name)
  end
end

Given(/^I have a mission$/) do
  @mission = Generator.mission!({ public: true })
  @mission.save!
end

When(/^I view the mission/) do
  visit "/missions/#{@mission.id}"
end

When(/^I clone the mission/) do
  visit(mission_path(@mission))
  click_link("Clone")
end

When(/^I view a mission$/) do
  @mission = Generator.mission!
  visit "/missions/#{@mission.id}"
end

Then(/^I see that mission$/) do
  expect(page).to have_content(@mission.name)
  expect(page).to have_content(@mission.description)
end

Then(/^I should see a cloned mission$/) do
  expect(page).to have_content(@mission.name + " (clone)")
  expect(page).to have_content(@mission.description)
end
