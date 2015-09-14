class User < ActiveRecord::Base
  SOURCES = {
    twitter: 1
  }.freeze

  enum({ source: SOURCES })

  has_many(:participants)
  has_many(:missions, {
    through: :participants,
    source: :joinable,
    source_type: "Mission"
  })

  validates(:name, { presence: true })

  def test
    super || reload && super
  end
end
