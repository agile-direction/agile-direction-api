class MissionsController < ApplicationController
  VALID_MISSION_PARAMS = %w(name description public)
  PAGE_LIMIT = 10

  before_action(:set_mission, {
    only: [:show, :edit, :update, :destroy, :order_deliverables, :clone]
  })

  before_action({ only: [:show, :edit, :update] }) do
    require_user! unless (@mission.public? || @mission.users.none?)
  end

  def index
    page = params[:page].to_i
    query = Mission.where({ public: true }).order({ updated_at: :desc })
    @missions = query.offset((page * PAGE_LIMIT)).limit(PAGE_LIMIT)

    @links = generate_links(query, page, PAGE_LIMIT) do |page_param|
      missions_path({ page: page_param })
    end

    respond_to do |format|
      format.html do
      end

      format.json do
        render({
          json: {
            missions: @missions
          }
        })
      end
    end
  end

  def show
    authorize!(:read, @mission)
    @participants = @mission.participants
    @mission = Mission.where({ id: params[:id] }).includes(:deliverables, :requirements).first
  end

  def new
    @mission = Mission.new
  end

  def edit
    authorize!(:write, @mission)
  end

  def create
    @mission = Mission.new(mission_params)
    if !@mission.public? && !current_user
      return redirect_to(auth_path, { status: 302 })
    end

    respond_to do |format|
      if @mission.save
        @mission.users << current_user if current_user
        format.html { redirect_to @mission, notice: "Mission was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize!(:write, @mission)

    respond_to do |format|
      if @mission.update(mission_params)
        format.html { redirect_to @mission, notice: "Mission was successfully updated." }
        format.json { render :show, status: :ok, location: @mission }
      else
        format.html { render :edit }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  def order_deliverables
    authorize!(:write, @mission)

    deliverable_params = params.permit({ deliverables: [:id] })
    deliverables = deliverable_params["deliverables"].each_with_index.collect do |deliverable_param, index|
      deliverable = Deliverable.find(deliverable_param["id"])
      deliverable.ordering = index
      deliverable
    end

    respond_to do |format|
      deliverables.collect(&:save!)
      format.json { render json: @mission }
    end
  end

  def clone
    new_mission = @mission.clone!
    redirect_to(mission_path(new_mission))
  end

  private

  def set_mission
    @mission = Mission.find(params[:id])
  end

  def mission_params
    params.require(:mission).permit(VALID_MISSION_PARAMS)
  end
end
