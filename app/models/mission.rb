class Mission < ActiveRecord::Base
  validates(:name, { presence: true })

  has_many(:deliverables, -> { order({ ordering: :asc }) })
  has_many(:requirements, { through: :deliverables })

  has_many(:participants, { as: :joinable })
  has_many(:users, { through: :participants })

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
