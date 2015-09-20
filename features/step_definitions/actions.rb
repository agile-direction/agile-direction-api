When(/^I delete "(.+)"$/) do |deliverable|
  click_on(deliverable)
  accept_alert do
    click_on("Delete")
  end
end
