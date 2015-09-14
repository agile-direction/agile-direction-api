require 'rails_helper'

RSpec.describe(RequirementsController, { type: :controller }) do
  include APIHelpers

  before(:all) do
    @participant = Generator.user!
    @non_participant = Generator.user!
    @mission = Generator.mission!
    @deliverable = Generator.deliverable!({ mission: @mission })
    @route_params = { mission_id: @mission.id, deliverable_id: @deliverable.id }
    @requirement = Generator.requirement!({ deliverable: @deliverable })
  end

  describe "GET #new" do
    it "allows anyone for unowned missions" do
      get(:new, @route_params)
      expect(response.status).to eq(200)
    end

    it "allows participants of owned missions" do
      login!(@participant) do
        get(:new, @route_params)
      end
      expect(response).to be_ok
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        get(:new, @route_params)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        get(:new, @route_params)
      end
      expect(response.status).to eq(403)
    end
  end

  describe "POST create" do
    it "creates requirement" do
      params = {
        name: Faker::Name.name,
        ordering: rand(10),
        description: Faker::Lorem.sentence,
        estimate: rand(10)
      }
      expect {
        post(:create, @route_params.merge({ requirement: params }))
      }.to change { Requirement.count }.by(1)
      expect(Requirement.order({ created_at: :desc }).first.attributes).to include(params.stringify_keys)
    end

    it "allows anyone for unowned missions" do
      expect {
        post(:create, @route_params.merge({ requirement: Generator.requirement.attributes }))
      }.to change { Requirement.count }.by(1)
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        expect {
          post(:create, @route_params.merge({ requirement: Generator.requirement.attributes }))
        }.to change { Requirement.count }.by(1)
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        expect {
          post(:create, @route_params.merge({ requirement: Generator.requirement.attributes }))
        }.to change { Requirement.count }.by(0)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "deos not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        expect {
          post(:create, @route_params.merge({ requirement: Generator.requirement.attributes }))
        }.to change { Requirement.count }.by(0)
      end
      expect(response.status).to eq(403)
    end
  end

  describe "GET #edit" do
    it "assigns the requested requirement as @requirement" do
      get(:edit, @route_params.merge({ id: @requirement.to_param }))
      expect(assigns(:requirement)).to eq(@requirement)
    end

    it "allows anyone for unowned missions" do
      get(:edit, @route_params.merge({ id: @requirement.to_param }))
      expect(response).to be_ok
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        get(:edit, @route_params.merge({ id: @requirement.to_param }))
      end
      expect(response).to be_ok
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        get(:edit, @route_params.merge({ id: @requirement.to_param }))
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        get(:edit, @route_params.merge({ id: @requirement.to_param }))
      end
      expect(response.status).to eq(403)
    end
  end

  describe "PUT #update" do
    it "updates the requested requirement" do
      new_data = {
        name: Faker::Name.name,
        ordering: rand(10),
        description: Faker::Lorem.sentence,
        estimate: rand(10),
        status: rand(2)
      }
      put(:update, @route_params.merge({ id: @requirement.id, requirement: new_data }))
      new_data[:status] = new_data[:status].to_i
      expect(@requirement.reload.attributes).to include(new_data.stringify_keys)
    end

    it "redirects to the mission" do
      put(:update, @route_params.merge({ id: @requirement.id, requirement: { name: Faker::Name.name } }))
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "re-renders the 'edit' template" do
      put(:update, @route_params.merge({ id: @requirement.id, requirement: { name: nil } }))
      expect(response).to render_template(:edit)
      expect(assigns(:requirement)).to eq(@requirement)
    end

    it "allows anyone for unowned missions" do
      put(:update, @route_params.merge({ id: @requirement.id, requirement: { name: Faker::Name.name } }))
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        put(:update, @route_params.merge({ id: @requirement.id, requirement: { name: Faker::Name.name } }))
      end
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        put(:update, @route_params.merge({ id: @requirement.id, requirement: { name: Faker::Name.name } }))
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        put(:update, @route_params.merge({ id: @requirement.id, requirement: { name: Faker::Name.name } }))
      end
      expect(response.status).to eq(403)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested requirement" do
      expect {
        delete(:destroy, @route_params.merge({ id: @requirement.to_param }))
      }.to change { Requirement.count }.by(-1)
    end

    it "redirects to the mission" do
      delete(:destroy, @route_params.merge({ id: @requirement.to_param }))
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "allows anyone for unowned missions" do
      expect {
        delete(:destroy, @route_params.merge({ id: @requirement.to_param }))
      }.to change { Requirement.count }.by(-1)
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        expect {
          delete(:destroy, @route_params.merge({ id: @requirement.to_param }))
        }.to change { Requirement.count }.by(-1)
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        expect {
          delete(:destroy, @route_params.merge({ id: @requirement.to_param }))
        }.to change { Requirement.count }.by(0)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        expect {
          delete(:destroy, @route_params.merge({ id: @requirement.to_param }))
        }.to change { Requirement.count }.by(0)
      end
      expect(response.status).to eq(403)
    end
  end
end
