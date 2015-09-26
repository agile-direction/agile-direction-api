class UsersController < ApplicationController
  before_action(:require_user!, { only: %w(show activity) })
  before_action(:load_user, { only: %w(show activity) })
  before_action(:authorize_user!, { only: %w(show activity) })
  FIND_LIMIT = 5
  MISSION_LIMIT = 10

  def index
    @users = User.order({ updated_at: :desc }).limit(FIND_LIMIT).where("name ilike ?", "%#{params[:term]}%")

    respond_to do |format|
      format.json do
        render({ json: @users.to_json })
      end
    end
  end

  def show
  end

  def activity
    page = params[:page].to_i
    query = @user.missions.order({ updated_at: :desc })
    @missions = query.limit(MISSION_LIMIT).offset(page * MISSION_LIMIT)

    @links = generate_links(query, page, MISSION_LIMIT) do |page_param|
      activity_user_path(@user, { page: page_param })
    end
  end

  private

  def load_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    authorize!(:write, @user)
  end
end
