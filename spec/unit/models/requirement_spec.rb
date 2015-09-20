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

  describe("#estimate") do
    it "sums estimates from all requirements" do
      mission = Mission.create!(name: Faker::Name.name)
      deliverable_1 = mission.deliverables.create!(name: Faker::Name.name)

      estimates_1 = rand(5).times.collect{rand(100)}
      estimates_1.each do |estimate|
        deliverable_1.requirements.create!(name:Faker::Name.name, estimate: estimate)
      end

      deliverable_2 = mission.deliverables.create!(name: Faker::Name.name)

      estimates_2 = rand(5).times.collect{rand(100)}
      estimates_2.each do |estimate|
        deliverable_2.requirements.create!(name:Faker::Name.name, estimate: estimate)
      end

      expect(mission.estimate).to eq(estimates_1.sum + estimates_2.sum)
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

      progress = mission.progress
      estimate = mission.estimate

      progress.keys.each do |key|
        expect(progress[key]).to eq((100*(status_estimate_map[key].sum.fdiv(estimate))).round(2))
      end
    end
  end
end

