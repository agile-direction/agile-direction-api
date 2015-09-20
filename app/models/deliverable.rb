class Deliverable < ActiveRecord::Base
  belongs_to(:mission)
  has_many(:requirements, -> { order "ordering DESC" })
  validates :name, { presence: true }
  validates :mission, { presence: true }

  def progress
    progress = requirements.each_with_object(Hash.new(0)) do |e, a|
      a[e.status] += (e.estimate * 100).fdiv(estimate)
      a
    end
    progress.each { |key, value| progress[key] = value.round(2) }
  end

  def estimate
    requirements.sum(:estimate)
  end
end
