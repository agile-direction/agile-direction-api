class HomeController < ApplicationController
  MISSION_LIMIT = 30

  def index
    @mission_count = Mission.count
    @missions = Mission
      .select(:name)
      .where({ public: true })
      .order({ updated_at: :desc })
      .limit(MISSION_LIMIT)
  end

  def glossary
  end
end
