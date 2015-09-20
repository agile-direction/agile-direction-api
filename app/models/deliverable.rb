class Deliverable < ActiveRecord::Base
  belongs_to(:mission)
  has_many(:requirements, -> { order({ ordering: :asc }) }, { dependent: :destroy })
  validates(:name, { presence: true })
  validates(:mission, { presence: true })
end
