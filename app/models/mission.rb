class Mission < ActiveRecord::Base
  validates(:name, { presence: true })

  has_many(:deliverables, -> { order({ ordering: :asc }) })
  has_many(:requirements, { through: :deliverables })

  has_many(:participants, { as: :joinable })
  has_many(:users, { through: :participants })
  belongs_to(:parent, { class_name: "Mission" })
  has_many(:clones, { class_name: "Mission", foreign_key: :parent_id })

  def clone!
    new_mission = dup
    new_mission.name = I18n.translate("activerecord.attributes.mission.cloned_name", { name: name })
    new_mission.parent = self
    new_mission.participants = participants.collect(&:dup)
    new_mission.deliverables = deliverables.collect do |deliverable|
      new_deliverable = deliverable.dup
      new_deliverable.requirements = deliverable.requirements.collect do |requirement|
        new_requirement = requirement.dup
        new_requirement.status = :created
        new_requirement
      end
      new_deliverable
    end

    new_mission.save!
    new_mission
  end

  def status
    requirements = Requirement
      .joins(:deliverable)
      .where({ deliverables: { mission_id: id } })
      .select("SUM(estimate) as time", :status)
      .group(:status)
    requirements.each_with_object(default_statuses) do |object, statuses|
      statuses[object.status] = object.time
    end
  end

  private

  def default_statuses
    Requirement.statuses.keys.each_with_object({}) do |status, statuses|
      statuses[status] = 0
    end
  end
end
