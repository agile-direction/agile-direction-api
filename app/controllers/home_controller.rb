class HomeController < ApplicationController
  MISSION_LIMIT = 30

  def index
    @mission_count = Mission.count
  end

  def glossary
  end
end
