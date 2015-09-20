require 'rails_helper'

RSpec.describe "deliverables/new", type: :view do
  before(:each) do
    @mission = Mission.create!({ name: Faker::Name.name })
    assign(:deliverable, Deliverable.new({ mission: @mission }))
  end

  it "renders new deliverable form" do
    render
    assert_select("form[action=?][method=?]", mission_deliverables_path(@mission, { action: :create }), "post")
  end
end
