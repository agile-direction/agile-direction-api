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
end

