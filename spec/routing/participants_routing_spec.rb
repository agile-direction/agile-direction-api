require "rails_helper"

RSpec.describe(ParticipantsController, { type: :routing }) do
  it "routes to #new" do
    expect({
      get: "/missions/1/participants/new"
    }).to route_to("participants#new", {
      mission_id: "1"
    })
  end

  it "routes to #create" do
    expect({
      post: "/missions/1/participants"
    }).to route_to("participants#create", {
      mission_id: "1"
    })
  end

  it "routes to #destroy" do
    expect({
      delete: "/missions/1/participants/2"
    }).to route_to("participants#destroy", {
      mission_id: "1",
      id: "2"
    })
  end
end
