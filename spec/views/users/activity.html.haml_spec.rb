require 'rails_helper'

RSpec.describe("users/activity", { type: :view }) do
  it "renders the activity page" do
    assign(:links, {})
    assign(:missions, [])
    render
  end

  it "shows mission names" do
    assign(:links, {})
    missions = 2.times.collect { Generator.mission! }
    assign(:missions, missions)
    render
    missions.each do |mission|
      expect(rendered).to match(mission.name)
    end
  end
end
