class UsersController < ApplicationController
  before_action(:require_user!, { only: %w(show) })
  before_action(:load_user, { only: %w(show) })
  before_action(:authorize_user!, { only: %w(show) })
  FIND_LIMIT = 5

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

  private

  def load_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    authorize!(:write, @user)
  end
end
