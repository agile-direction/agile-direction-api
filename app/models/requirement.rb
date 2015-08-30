class Requirement < ActiveRecord::Base
  include AASM

  belongs_to(:deliverable)
  has_one(:mission, { through: :deliverable })

  validates(:name, { presence: true })
  validates(:deliverable, { presence: true })

  before_validation :set_defaults

  enum status: [:created, :started, :completed]

  aasm column: :status do
    state :created, initial: true
    state :started
    state :completed

    event :start do
      transitions from: :created, to: :started
    end

    event :finish do
      transitions from: :started, to: :completed
    end
  end

  def set_defaults
    self.ordering ||= 0
  end
end
