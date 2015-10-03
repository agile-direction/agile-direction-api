class DeliverablesController < ApplicationController
  before_action(:set_mission)
  before_action(:set_deliverable)
  before_action do
    require_user! unless @deliverable.mission.users.none?
  end

  def new
    authorize!(:create, @deliverable)
  end

  def edit
    authorize!(:update, @deliverable)
  end

  def create
    @deliverable = @mission.deliverables.new(deliverable_params)
    authorize!(:update, @deliverable)
    default_ordering!(@deliverable)

    respond_to do |format|
      if @deliverable.save
        format.html do
          redirect_to(success_redirect_path(@deliverable), {
            notice: t("flashes.create.success")
          })
        end
        format.json do
          render(:show, {
            status: :created,
            location: @deliverable
          })
        end
      else
        format.html { render :new }
        format.json { render json: @deliverable.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize!(:update, @deliverable)

    respond_to do |format|
      if @deliverable.update(deliverable_params)
        format.html do
          redirect_to(success_redirect_path(@deliverable), {
            notice: t("flashes.update.success")
          })
        end
        format.json do
          render(:show, {
            status: :ok,
            location: @deliverable
          })
        end
      else
        format.html { render :edit }
        format.json { render json: @deliverable.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize!(:destroy, @deliverable)

    @deliverable.destroy
    respond_to do |format|
      format.html do
        redirect_to(@deliverable.mission, {
          notice: t("flashes.destroy.success")
        })
      end
      format.json { head :no_content }
    end
  end

  def order_requirements
    authorize!(:update, @deliverable)

    requirement_params = params.permit({ requirements: [:id] })
    requirements = requirement_params["requirements"].each_with_index.collect do |requirement_param, index|
      requirement = Requirement.find(requirement_param["id"])
      requirement.ordering = index
      requirement.deliverable = @deliverable
      requirement
    end

    respond_to do |format|
      requirements.collect(&:save!)
      format.json { render json: @deliverable }
    end
  end

  private

  def default_ordering!(deliverable)
    deliverable.ordering = deliverable.mission.deliverables.count
  end

  def success_redirect_path(deliverable)
    mission_path(deliverable.mission, anchor_for(deliverable))
  end

  def set_deliverable
    if params[:id]
      @deliverable = Deliverable.find(params[:id])
    else
      @deliverable = Deliverable.new({ mission: @mission })
    end
  end

  def set_mission
    @mission = Mission.find(params[:mission_id])
  end

  def deliverable_params
    params.require(:deliverable).permit(%w(name value ordering))
  end
end
