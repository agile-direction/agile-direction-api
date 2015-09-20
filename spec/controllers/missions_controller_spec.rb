require 'rails_helper'

RSpec.describe(MissionsController, { type: :controller }) do
  include APIHelpers

  before(:all) do
    @ashish = Generator.user!
    @geoff = Generator.user!
  end

  describe "GET #index" do
    it "shows unowned missions" do
      mission = Generator.mission!
      get(:index)
      expect(assigns(:missions)).to include(mission)
    end

    it "shows public missions" do
      mission = Generator.mission!({ public: true })
      get(:index)
      expect(assigns(:missions)).to include(mission)
    end

    it "does not show private missions" do
      mission = Generator.mission!({ public: false })
      get(:index)
      expect(assigns(:missions)).to_not include(mission)
    end

    it "supports json requests" do
      mission = Generator.mission!
      add_json_headers!
      get(:index)
      expect(response).to be_ok
      expect(json_response["missions"].first["id"]).to eq(mission.id)
    end
  end

  describe "POST #create" do
    it "creates mission" do
      mission = Generator.mission
      expect {
        post(:create, { mission: mission.attributes })
      }.to change {
        Mission.count
      }.by(1)

      expect(Mission.order({ created_at: :desc }).first.name).to eq(mission.name)
    end

    it "add user as a participant of mission" do
      ashish = Generator.user!
      login!(ashish) do
        expect {
          post(:create, { mission: Generator.mission.attributes })
        }.to change { ashish.missions.count }.by(1)
      end
    end

    it "redirects to the created mission" do
      post(:create, { mission: Generator.mission.attributes })
      expect(response).to redirect_to(Mission.order({ created_at: :desc }).first)
    end

    it "re-renders the 'new' template" do
      mission = Generator.mission({ name: nil })
      post(:create, { mission: mission.attributes })
      expect(assigns(:mission)).to be_a_new(Mission)
      expect(response).to render_template("new")
    end

    it "creates unowned missions for anonymous users" do
      login! do
        post(:create, { mission: Generator.mission.attributes })
        expect(Mission.order({ created_at: :desc }).first.users).to be_blank
      end
    end

    it "creates public missions for anonymous users" do
      mission = Generator.mission({ public: true })
      login! do
        post(:create, { mission: mission.attributes })
        expect(Mission.order({ created_at: :desc }).first).to be_public
      end
    end

    it "does not create private missions for anonymous users" do
      mission = Generator.mission({ public: false })
      login! do
        expect {
          post(:create, { mission: mission.attributes })
        }.to_not change {
          Mission.count
        }
      end
    end

    it "creates owned missions for users" do
      login!(@geoff) do
        expect {
          post(:create, { mission: Generator.mission.attributes })
        }.to change { @geoff.missions.count }.by(1)
      end
    end

    it "creates private missions for users" do
      private_mission = Generator.mission({ public: false })
      login!(@geoff) do
        expect {
          post(:create, { mission: private_mission.attributes })
        }.to change { Mission.count }.by(1)
      end
    end

    it "creates public missions for users" do
      public_mission = Generator.mission({ public: true })
      login!(@geoff) do
        expect {
          post(:create, { mission: public_mission.attributes })
        }.to change { Mission.count }.by(1)
      end
    end
  end

  describe "GET #show" do
    it "shows public missions without participants to everyone" do
      mission = Generator.mission!({ public: true })
      get(:show, { id: mission.id })
      expect(response).to be_ok
    end

    it "shows public missions with participants to everyone" do
      mission = Generator.mission!({ public: true })
      mission.users << Generator.user!
      get(:show, { id: mission.id })
      expect(response).to be_ok
    end

    it "shows private missions to contributors" do
      mission = Generator.mission!({ public: false, users: [@ashish] })
      login!(@ashish) { get(:show, { id: mission.id }) }
      expect(response).to be_ok
    end

    it "does not show private missions to non-contributors" do
      mission = Generator.mission!({ public: false, users: [@ashish] })
      login!(@geoff) { get(:show, { id: mission.id }) }
      expect(response.status).to eq(403)
    end

    it "does not show private missions to anonymous users" do
      mission = Generator.mission!({ public: false, users: [@ashish] })
      login! { get(:show, { id: mission.id }) }
      expect(response).to redirect_to(auth_path)
    end
  end

  describe "PUT #update" do
    before(:each) do
      @mission = Generator.mission!
    end

    it "updates the missions" do
      new_attributes = {
        "name" => Faker::Name.name,
        "description" => Faker::Lorem.sentence
      }
      put(:update, { id: @mission.id, mission: new_attributes })
      expect(@mission.reload.attributes).to include(new_attributes)
    end

    it "redirects to the mission" do
      put(:update, { id: @mission.id, mission: { name: Faker::Name.name } })
      expect(response).to redirect_to(@mission)
    end

    it "re-renders the 'edit' template with errors" do
      put(:update, { id: @mission.id, mission: { name: nil } })
      expect(response).to render_template("edit")
    end

    it "updates unowned missions by anyone" do
      mission = Generator.mission!
      new_name = Faker::Name.name
      put(:update, { id: mission.id, mission: { name: new_name } })
      expect(response.status).to eq(302)
      expect(mission.reload.name).to eq(new_name)
    end

    it "updates owned missions by contributors" do
      mission = Generator.mission!({ users: [@geoff] })
      new_name = Faker::Name.name
      login!(@geoff) do
        put(:update, { id: mission.id, mission: { name: new_name } })
      end
      expect(mission.reload.name).to eq(new_name)
    end

    it "does not update missions by non-contributors" do
      mission = Generator.mission!({ users: [@geoff] })
      new_name = Faker::Name.name
      login!(@ashish) do
        put(:update, { id: mission.id, mission: { name: new_name } })
      end
      expect(mission.reload.name).to_not eq(new_name)
    end
  end

  describe "PUT #order" do
    it "reorders deliverables" do
      mission = Generator.mission!
      first_deliverable, second_deliverable = 2.times.collect do |i|
        Generator.deliverable!({ mission: mission, ordering: i })
      end

      add_json_headers!
      put(:order_deliverables, {
        id: mission.id,
        deliverables: [{
          id: second_deliverable.id
        }, {
          id: first_deliverable.id
        }]
      })

      expect(response).to be_successful
      expect(first_deliverable.reload.ordering).to eq(1)
      expect(second_deliverable.reload.ordering).to eq(0)
    end

    it "redorders deliverables of unowned missions by anyone" do
      add_json_headers!
      mission = Generator.mission!({
        deliverables: 2.times.collect { Generator.deliverable }
      })
      put(:order_deliverables, {
        id: mission.id,
        deliverables: mission.deliverables.collect(&:attributes)
      })
      expect(response.status).to eq(200)
    end

    it "reorders deliverables of missions by contributor" do
      add_json_headers!
      mission = Generator.mission!({
        users: [@ashish],
        deliverables: 2.times.collect { Generator.deliverable }
      })

      login!(@ashish) do
        put(:order_deliverables, {
          id: mission.id,
          deliverables: mission.deliverables.collect(&:attributes)
        })
      end
      expect(response.status).to eq(200)
    end

    it "does not reorder deliverables of missions by anonymous users" do
      add_json_headers!
      mission = Generator.mission!({
        users: [@ashish],
        deliverables: 2.times.collect { Generator.deliverable }
      })

      login! do
        put(:order_deliverables, {
          id: mission.id,
          deliverables: mission.deliverables.collect(&:attributes)
        })
      end
      expect(response.status).to eq(403)
    end

    it "does not reorder deliverables of missions by non-contributors" do
      add_json_headers!
      mission = Generator.mission!({
        users: [@ashish],
        deliverables: 2.times.collect { Generator.deliverable }
      })

      login!(@geoff) do
        put(:order_deliverables, {
          id: mission.id,
          deliverables: mission.deliverables.collect(&:attributes)
        })
      end
      expect(response.status).to eq(403)
    end
  end

  describe "POST clone" do
    it "creates clone" do
      mission = Generator.mission!
      expect {
        post(:clone, { id: mission.to_param })
      }.to change(Mission, :count).by(1)
    end

    it "redirects to clone" do
      mission = Generator.mission!
      post(:clone, { id: mission.clone })
      expect(response).to redirect_to(mission_path(Mission.order({ created_at: :desc }).first))
    end
  end
end
