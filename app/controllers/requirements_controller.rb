class RequirementsController < ApplicationController
  before_action(:set_requirement, {
    except: [:index]
  })

  before_action({ only: [:new, :show, :create, :edit, :update, :destroy] }) do
    require_user! unless @requirement.mission.users.none?
  end

  def index
    @requirements = Requirement.all
  end

  def new
    authorize!(:create, @requirement)
  end

  def edit
    authorize!(:write, @requirement)
  end

  def create
    @deliverable = find_deliverable
    @requirement = @deliverable.requirements.new(requirement_params)
    authorize!(:create, @requirement)

    respond_to do |format|
      if @requirement.save
        format.html do
          redirect_to(success_redirect_path, {
            notice: t("flashes.create.success")
          })
        end
        format.json { render :show, status: :created, location: @requirement }
      else
        format.html { render :new }
        format.json { render json: @requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize!(:write, @requirement)

    respond_to do |format|
      if @requirement.update(requirement_params)
        format.html do
          redirect_to(success_redirect_path, {
            notice: t("flashes.update.success")
          })
        end
        format.json do
          render(:show, {
            status: :ok,
            location: @requirement
          })
        end
      else
        format.html { render :edit }
        format.json { render json: @requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize!(:destroy, @requirement)

    @requirement.destroy

    respond_to do |format|
      format.html do
        redirect_to(mission_path(@requirement.mission), {
          notice: "Requirement was successfully destroyed."
        })
      end
      format.json { head :no_content }
    end
  end

  private

  def success_redirect_path
    mission_path(@requirement.mission, {
      anchor: @requirement.to_param
    })
  end

  def find_deliverable
    Deliverable.where({ id: params[:deliverable_id] }).includes(:mission).first
  end

  def set_requirement
    if params[:id]
      @requirement = Requirement.where({
        id: params[:id]
      }).includes(:deliverable, :mission).first
    else
      deliverable = Deliverable.where({ id: params[:deliverable_id] }).includes(:mission).first
      @requirement = Requirement.new({
        deliverable: deliverable,
        mission: deliverable.mission
      })
    end
  end

  def requirement_params
    string_params = params.require(:requirement).permit(%w(name description ordering estimate status))
    string_params["status"] = string_params["status"].to_i
    string_params
  end
end
