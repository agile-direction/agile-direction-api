require 'rails_helper'

RSpec.describe "requirements/new", type: :view do
  before(:each) do
    @deliverable = Generator.deliverable!
    assign(:requirement, Requirement.new({ deliverable: @deliverable, mission: @deliverable.mission }))
  end

  it "renders new requirement form" do
    render
    assert_select("form[action=?][method=?]", mission_deliverable_requirements_path(@deliverable.mission, @deliverable, { action: :create }), "post") do
    end
  end
end
