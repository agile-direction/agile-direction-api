require 'rails_helper'

RSpec.describe "missions/index", type: :view do
  before(:each) do
    assign(:links, {})
    assign(:missions, 2.times.collect {
      Mission.create!({ name: Faker::Name.name })
    })
    assign(:page, 0)
    assign(:mission_count, 2)
    assign(:missions_per_page, 10)
  end

  it "renders a list of missions" do
    assign(:links, {})
    render
  end
end
