require 'rails_helper'

RSpec.describe Mission, type: :model do
  describe("validations") do
    it("validates name") do
      mission = Mission.new
      expect(mission.valid?).to be(false)
      expect(mission.errors[:name]).to_not be_empty
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
