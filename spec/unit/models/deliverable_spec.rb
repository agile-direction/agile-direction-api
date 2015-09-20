require "rails_helper"

RSpec.describe(Deliverable, { type: :model }) do
  describe("validations") do
    it("requires name") do
      deliverable = Deliverable.new
      expect(deliverable.valid?).to be_falsy
      expect(deliverable.errors.keys).to include(:name)
      expect(deliverable.errors[:name]).to include("can't be blank")
    end

    it("requires mission") do
      deliverable = Deliverable.new
      expect(deliverable.valid?).to be_falsy
      expect(deliverable.errors.keys).to include(:mission)
      expect(deliverable.errors[:mission]).to include("can't be blank")
    end
  end

  describe("#estimate") do
    it "sums estimates from all requirements" do
      mission = Mission.create!(name: Faker::Name.name)
      deliverable = mission.deliverables.create!(name: Faker::Name.name)

      estimates = 2.times.collect{rand(100)}
      estimates.each do |estimate|
        deliverable.requirements.create!(name:Faker::Name.name, estimate: estimate)
      end

      expect(deliverable.estimate).to eq(estimates.sum)
    end
  end

  describe("#progress") do
    it "takes average over all requirements based on estimate and status" do
      mission = Mission.create!(name: Faker::Name.name)
      deliverable = mission.deliverables.create!(name: Faker::Name.name)

      status_estimate_map = %w(created started completed).each_with_object({}) do |e, a|
        a[e] = rand(3).times.collect { rand(100)}
      end

      status_estimate_map.each do |status, estimates|
        estimates.each do |estimate|
          deliverable.requirements.create!(name:Faker::Name.name, estimate: estimate, status: status)
        end
      end

      progress = deliverable.progress
      estimate = deliverable.estimate

      progress.keys.each do |key|
        expect(progress[key]).to eq((100*(status_estimate_map[key].sum.fdiv(estimate))).round(2))
      end
    end
  end
end

