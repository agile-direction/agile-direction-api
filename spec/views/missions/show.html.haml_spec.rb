require 'rails_helper'

RSpec.describe "missions/show", type: :view do
  before(:each) do
  end

  it "renders attributes" do
    name = Faker::Name.name
    description = Faker::Lorem.sentence

    @mission = assign(:mission, Mission.create!({
      name: name,
      description: description
    }))

    render
    expect(rendered).to match(name)
    expect(rendered).to match(description)
  end

  it "renders deliverables" do
    @mission = assign(:mission, Generator.mission!)
    render
    expect(rendered).to match(@mission.name)
  end
end
