require 'rails_helper'

RSpec.describe RequirementsController, type: :controller do
  include AuthHelpers
  include APIHelpers

  before(:all) do
    @public_mission = Generator.mission!({ public: true })
    @public_deliverable = Generator.deliverable!({ mission: @public_mission })
    @public_route_params = {
      deliverable_id: @public_deliverable.id,
      mission_id: @public_mission.id
    }

    @private_mission = Generator.mission!({ public: false })
    @private_deliverable = Generator.deliverable!({ mission: @private_mission })
    @private_route_params = {
      deliverable_id: @private_deliverable.id,
      mission_id: @private_mission.id
    }
  end

  let(:valid_attributes) { { name: Faker::Name.name, deliverable_id: @deliverable.id } }
  let(:invalid_attributes) { { name: nil } }
  let(:valid_session) { {} }

  describe "GET new" do
    it "allows anyone for public missions" do
      get(:new, @public_route_params)
      expect(response.status).to eq(200)
    end

    it "ensures user for private missions" do
      get(:new, @private_route_params)
      expect(response).to redirect_to(auth_path)
    end

    it "disables non-contributors for private missions" do
      login!(Generator.user!) do
        get(:new, @private_route_params)
        expect(response.status).to eq(403)
      end
    end

    it "allows contributors for private missions" do
      geoff = Generator.user!
      @private_mission.users << geoff
      login!(geoff) do
        get(:new, @private_route_params)
        expect(response.status).to eq(200)
      end
    end
  end

  describe "POST create" do
    it "allows anyone to create requirments for public missions" do
    end
  end

  xdescribe "public missions" do
    before(:each) do
      @mission = Generator.mission!({ public: true })
      @deliverable = Generator.deliverable!({ mission: @mission })
      @route_params = {
        deliverable_id: @deliverable.id,
        mission_id: @mission.id
      }
    end

    it "it allows anyone to create requirments" do
      with_api_test(@route_params) do |api|
        api.new
        expect(response.status).to eq(200)
        expect { api.create!(Generator.requirement) }.to change { Requirement.count }.by(1)
      end
      created_record = assigns(:requirement)
      expect(created_record.deliverable).to eq(@deliverable)
      expect(created_record.mission).to eq(@mission)
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "allows anyone to see requirements" do
      requirement = Generator.requirement!({ deliverable: @deliverable })
      with_api_test(@route_params) do |api|
        api.show(requirement)
        expect(response.status).to eq(200)
      end
    end

    it "allows anyone to edit requirements" do
      requirement = Generator.requirement!({ deliverable: @deliverable })
      with_api_test(@route_params) do |api|
        api.edit(requirement)
        expect(response.status).to eq(200)

        update_data = { name: Faker::Name.name }
        expect_change!(requirement, update_data) do
          api.update!(requirement, update_data)
          expect(response).to redirect_to(mission_path(requirement.mission))
        end
      end
    end

    it "allows anyone to delete requirements" do
      requirement = Generator.requirement!({ deliverable: @deliverable })
      with_api_test(@route_params) do |api|
        expect { api.destroy!(requirement) }.to change { Requirement.count }.by(-1)
        expect(response).to redirect_to(mission_path(@mission))
      end
    end
  end

  xdescribe "requirements of private missions" do
    before(:each) do
      @mission = Generator.mission!({ public: false })
      @deliverable = Generator.deliverable!({ mission: @mission })
      @relationship_params = {
        deliverable_id: @deliverable.id,
        mission_id: @mission.id
      }
      @update_data = { name: Faker::Name.name }
    end

    it "allows people apart of a private mission to manage its requirements" do
      geoff = Generator.user!
      @mission.users << geoff

      login!(geoff) do
        created_requirement = expect_createable!(Generator.requirement, @relationship_params)
        expect_manageable!(created_requirement, @update_data, @relationship_params)
        expect_destroyable!(created_requirement, @relationship_params)
      end
    end

    it "does not allow guests to create or manage requirements of private missions" do
      expect_collection_change!(Requirement, 0) do
        api_create!(Generator.requirement, @relationship_params)
      end

      requirement = Generator.requirement!({ deliverable: @deliverable })
      expect_unmanageable!(requirement, @update_data, 302, @relationship_params)

      expect_collection_change!(Requirement, -1) do
        api_destroy!(requirement, @relationship_params)
      end
    end

    it "does not allow non-contributors to create or manage requirements to private missions" do
      login!(Generator.user!) do
        expect_new_records!(Requirement, 0) do
          create!(Generator.requirement, @relationship_params)
        end
        requirement = Generator.requirement!({ deliverable: @deliverable })
        expect_unmanageable!(requirement, @update_data, 403, @relationship_params)
      end
    end
  end

  xdescribe "GET #new" do
    it "assigns a new requirement as @requirement" do
      get :new, {mission_id: @mission.id, deliverable_id: @deliverable.id }, valid_session
      expect(assigns(:requirement)).to be_a_new(Requirement)
    end
  end

  xdescribe "GET #edit" do
    it "assigns the requested requirement as @requirement" do
      requirement = Requirement.create! valid_attributes
      get :edit, {mission_id: @mission.id, deliverable_id: @deliverable.id, id: requirement.to_param}, valid_session
      expect(assigns(:requirement)).to eq(requirement)
    end
  end

  xdescribe "POST #create" do
    context "with valid params" do
      it "creates a new Requirement" do
        expect {
          post :create, {mission_id: @mission.id, deliverable_id: @deliverable.id, :requirement => valid_attributes}, valid_session
        }.to change(Requirement, :count).by(1)
      end

      it "assigns a newly created requirement as @requirement" do
        post :create, {mission_id: @mission.id, deliverable_id: @deliverable.id, :requirement => valid_attributes}, valid_session
        expect(assigns(:requirement)).to be_a(Requirement)
        expect(assigns(:requirement)).to be_persisted
      end

      it "redirects to deliverable" do
        post :create, {mission_id: @mission.id, deliverable_id: @deliverable.id, :requirement => valid_attributes}, valid_session
        expect(response).to redirect_to(mission_path(@mission))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved requirement as @requirement" do
        post :create, {mission_id: @mission.id, deliverable_id: @deliverable.id,:requirement => invalid_attributes}, valid_session
        expect(assigns(:requirement)).to be_a_new(Requirement)
      end

      it "re-renders the 'new' template" do
        post :create, {mission_id: @mission.id, deliverable_id: @deliverable.id, :requirement => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  xdescribe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {name: Faker::Name.name}
      }

      it "updates the requested requirement" do
        requirement = Requirement.create! valid_attributes
        put :update, {mission_id: @mission.id, deliverable_id: @deliverable.id, id: requirement.to_param, :requirement => new_attributes}, valid_session
        requirement.reload
      end

      it "assigns the requested requirement as @requirement" do
        requirement = Requirement.create! valid_attributes
        put :update, {mission_id: @mission.id, deliverable_id: @deliverable.id, id:requirement.to_param, :requirement => valid_attributes}, valid_session
        expect(assigns(:requirement)).to eq(requirement)
      end

      it "redirects to the mission" do
        requirement = Requirement.create! valid_attributes
        put :update, {mission_id: @mission.id, deliverable_id: @deliverable.id, id: requirement.to_param, :requirement => valid_attributes}, valid_session
        expect(response).to redirect_to(mission_path(@mission))
      end
    end

    context "with invalid params" do
      it "assigns the requirement as @requirement" do
        requirement = Requirement.create! valid_attributes
        put :update, {mission_id: @mission.id, deliverable_id: @deliverable.id,:id => requirement.to_param, :requirement => invalid_attributes}, valid_session
        expect(assigns(:requirement)).to eq(requirement)
      end

      it "re-renders the 'edit' template" do
        requirement = Requirement.create! valid_attributes
        put :update, {mission_id: @mission.id, deliverable_id: @deliverable.id,:id => requirement.to_param, :requirement => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE #destroy" do
    it "destroys the requested requirement" do
      requirement = Requirement.create! valid_attributes
      expect {
        delete :destroy, {mission_id: @mission.id, deliverable_id: @deliverable.id, id: requirement.to_param}, valid_session
      }.to change(Requirement, :count).by(-1)
    end

    it "redirects to the mission" do
      requirement = Requirement.create! valid_attributes
      delete :destroy, {mission_id: @mission.id, deliverable_id: @deliverable.id, id: requirement.to_param}, valid_session
      expect(response).to redirect_to(mission_path(@mission))
    end
  end

  xdescribe "Put #start" do
    it "starts the requested requirement" do
      requirement = Requirement.create! valid_attributes
      expect(requirement.status).to eq("created")
      put :start,{mission_id: @mission.id, deliverable_id: @deliverable.id,:id => requirement.to_param}, valid_session
      expect(requirement.reload.status).to eq("started")
    end
  end

  xdescribe "Put #finish" do
    it "completes the requested requirement" do
      requirement = Requirement.create! valid_attributes.merge!( status: "started")
      expect(requirement.status).to eq("started")
      put :finish,{mission_id: @mission.id, deliverable_id: @deliverable.id,:id => requirement.to_param}, valid_session
      expect(requirement.reload.status).to eq("completed")
    end
  end

end
