class RequirementsController < ApplicationController
  before_action(:set_requirement, {
    except: [:index]
  })

  before_action({ only: [:new, :show] }) do
    require_user! unless @requirement.mission.public?
  end

  def index
    @requirements = Requirement.all
  end

  def show
    authorize!(:read, @requirement)
  end

  def new
    authorize!(:create, @requirement)
    @requirement = Requirement.new
  end

  def edit
    if !@requirement.mission.public? && !current_user
      return redirect_to(auth_path, { status: 302 })
    end
    authorize!(:write, @requirement)
  end

  def create
    @deliverable = find_deliverable
    @requirement = @deliverable.requirements.new(requirement_params)

    if !@deliverable.mission.public? && !current_user
      return redirect_to(auth_path, { status: 302 })
    end
    authorize!(:create, @requirement)

    respond_to do |format|
      if @requirement.save
        format.html do
          redirect_to(mission_path(@deliverable.mission), {
            notice: "Requirement was successfully created."
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
    if !@requirement.mission.public? && !current_user
      return redirect_to(auth_path, { status: 302 })
    end
    authorize!(:write, @requirement)

    respond_to do |format|
      if @requirement.update(requirement_params)
        format.html do
          redirect_to(mission_path(@requirement.mission), {
            notice: "Requirement was successfully created."
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

  def start
    respond_to do |format|
      if @requirement.start!
        format.html do
          redirect_to(mission_path(@requirement.mission), {
            notice: "Requirement was successfully started."
          })
        end

        format.json do
          render(:show, {
            status: :created,
            location: @requirement
          })
        end
      end
    end
  end

  def finish
    respond_to do |format|
      if @requirement.finish!
        format.html do
          redirect_to(mission_path(@requirement.mission), {
            notice: "Requirement was successfully completed."
          })
        end
        format.json do
          render(:show, {
            status: :created,
            location: @requirement
          })
        end
      end
    end
  end

  private

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
    params.require(:requirement).permit(%w(name description ordering estimate))
  end
end
