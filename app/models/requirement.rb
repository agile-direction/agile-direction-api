class Requirement < ActiveRecord::Base
  include AASM

  STATUSES = {
    created: 0,
    started: 1,
    completed: 2
  }
  enum({ status: STATUSES })

  belongs_to(:deliverable)
  has_one(:mission, { through: :deliverable })

  validates(:name, { presence: true })
  validates(:deliverable, { presence: true })

  aasm({ column: :status }) do
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
end
