require "rails_helper"

RSpec.describe(Requirement, { type: :model }) do
  describe("validations") do
    it("requires name") do
      requirement = Requirement.new
      expect(requirement.valid?).to be_falsy
      expect(requirement.errors.keys).to include(:name)
      expect(requirement.errors[:name]).to include("can't be blank")
    end

    it("requires deliverable") do
      requirement = Requirement.new
      expect(requirement.valid?).to be_falsy
      expect(requirement.errors.keys).to include(:deliverable)
      expect(requirement.errors[:deliverable]).to include("can't be blank")
    end
  end

  describe("status state machine") do
    before(:each) do
      mission = Mission.create!({ name: Faker::Name.name })
      deliverable = mission.deliverables.create!(mission: mission, name: "clean gotham's streets")
      @requirement = Requirement.create!(deliverable: deliverable,
                                         name: "bring back lau" ,
                                         description: "you just bring him back.. i will make him sing")
    end

    it "defaults status to created" do
      expect(@requirement.status).to eq("created")
    end

    %w(created started completed).each do |state|
      it "responses to #{state}?" do
        @requirement.update_attributes!(status: state)
        expect(@requirement.send("#{state}?")).to be_truthy
      end
    end

    describe("events") do
      it "start event changes status from created to started" do
        @requirement.start!
        expect(@requirement.status).to eq("started")
      end

      it "finish event changes status from started to completed" do
        @requirement.update_attributes!(status: "started")
        @requirement.finish!
        expect(@requirement.status).to eq("completed")
      end
    end
  end
end
