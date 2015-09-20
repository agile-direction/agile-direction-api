require 'rails_helper'

RSpec.describe Mission, type: :model do
  describe("validations") do
    it("validates name") do
      mission = Mission.new
      expect(mission.valid?).to be(false)
      expect(mission.errors[:name]).to_not be_empty
    end
  end

  describe("#clone") do
    before(:each) do
      @mission = Generator.mission!
    end

    it "duplicates mission" do
      expect {
        new_mission = @mission.clone!
        expect(new_mission.id).to_not eq(@mission.id)
      }.to change(Mission, :count).by(1)
    end

    it "adds 'duped' to the duplicated Mission's name" do
      new_mission = @mission.clone!
      expect(new_mission.name).to match(/clone/)
    end

    it "keeps track of its parent" do
      new_mission = @mission.clone!
      expect(new_mission.parent).to eq(@mission)
    end

    it "duplicates participants" do
      users = 2.times.collect { Generator.user!({ missions: [@mission] }) }
      new_mission = nil
      expect {
        new_mission = @mission.clone!
      }.to change(Participant, :count).by(2)
      expect(new_mission.users).to eq(users)
    end

    it "duplicates deliverables" do
      deliverables = 2.times.collect { Generator.deliverable!({ mission: @mission }) }
      new_mission = nil
      expect {
        new_mission = @mission.clone!
      }.to change(Deliverable, :count).by(2)
      Deliverable.order({ created_at: :desc }).limit(2).each do |deliverable|
        expect(deliverable.mission).to eq(new_mission)
      end
    end

    it "duplicates requirements" do
      deliverables = 2.times.collect { Generator.deliverable!({ mission: @mission }) }
      new_requirements = deliverables.collect do |deliverable|
        2.times.collect { Generator.requirement!({ mission: @mission, deliverable: deliverable }) }
      end.flatten

      new_mission = nil
      expect {
        new_mission = @mission.clone!
      }.to change(Requirement, :count).by(4)

      Requirement.order({ created_at: :desc }).limit(4).each do |requirement|
        expect(requirement.mission).to eq(new_mission)
        expect(deliverables).to_not include(requirement.deliverable)
      end
    end

    it "resets status of all requirements" do
      deliverable = Generator.deliverable!({ mission: @mission })
      requirement = Generator.requirement!({
        mission: @mission,
        deliverable: deliverable,
        status: Requirement.statuses.fetch("completed")
      })
      expect {
        @mission.clone!
      }.to change(Requirement, :count).by(1)
      expect(Requirement.order({ created_at: :desc }).first.created?).to be_truthy
    end
  end

  describe("#status") do
    it "summarizes estimates of requirements" do
      mission = Generator.mission!
      deliverables = 2.times.collect do
        Generator.deliverable!({ mission: mission })
      end
      requirements = 3.times.collect do
        Generator.requirement!({
          mission: mission,
          deliverable: deliverables.sample,
          estimate: rand(10),
          status: Requirement.statuses.keys.sample
        })
      end

      estimates = Requirement.statuses.each_with_object({}) do |(name, value), estimates|
        estimates[name] = mission.requirements.where({ status: value }).sum(:estimate)
      end
      expect(mission.status).to eq(estimates)
    end

  end
end
