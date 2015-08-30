class ParticipantsController < ApplicationController
  before_action(:set_mission)
  before_action({ only: [:new, :create, :destroy] }) do
    require_user! unless @mission.users.empty?
  end

  def new
    @participant = Participant.new({ joinable: @mission })
    authorize!(:create, @participant)
  end

  def create
    @participant = Participant.new(participant_params.merge({
      joinable: @mission
    }))
    authorize!(:create, @participant)
    @participant.save!
    redirect_to(mission_path(@mission))
  end

  def destroy
    @participant = Participant.find(params[:id])
    authorize!(:destroy, @participant)
    @participant.destroy!
    redirect_to(mission_path(@mission))
  end

  private

  def set_mission
    @mission = Mission.find(params[:mission_id])
  end

  def participant_params
    params.permit(:user_id)
  end
end
