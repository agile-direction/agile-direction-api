When(/^I add a user to the Mission$/) do
  @user = Generator.user!({ name: "Ashish" })
  find(:css, "a[title=\"Add Participant\"]").click
  fill_in("participant[user]", { with: "ash" })

  if (Capybara.current_driver == :poltergeist)
    find('input#add-user').native.send_key(:enter)
    find('input#add-user').trigger("click")
  end

  click_link(@user.name)
  sleep 1 # wait for js click action
end

Then(/^the user should be apart of the mission$/) do
  expect(@mission.reload.users).to include(@user)
end
