class Mission < ActiveRecord::Base
  validates(:name, { presence: true })

  has_many(:deliverables, -> { order "ordering DESC" })

  has_many(:participants, { as: :joinable })
  has_many(:users, { through: :participants })

  def progress
    requirements = deliverables.map(&:requirements).flatten!

    progress = requirements.each_with_object(Hash.new(0)) do |e, a|
      a[e.status] += (e.estimate * 100).fdiv(estimate)
      a
    end
    progress.each { |key, value| progress[key] = value.round(2) }
  end

  def estimate
    deliverables.map(&:estimate).sum
  end
end
