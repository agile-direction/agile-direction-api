require 'rails_helper'

RSpec.describe DeliverablesController, type: :controller do
  include APIHelpers

  def latest_deliverable
    Deliverable.order({ created_at: :desc }).first
  end

  before(:all) do
    @mission = Generator.mission!
    @deliverable = Generator.deliverable!({ mission: @mission })
    @participant = Generator.user!
    @non_participant = Generator.user!
  end

  describe "GET #new" do
    it "allows anyone for unowned missions" do
      get(:new, { mission_id: @mission.id })
      expect(assigns(:deliverable)).to be_a_new(Deliverable)
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        get(:new, { mission_id: @mission.id })
        expect(response).to be_successful
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        get(:new, { mission_id: @mission.id })
        expect(response).to redirect_to(auth_path)
      end
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        get(:new, { mission_id: @mission.id })
        expect(response.status).to eq(403)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested deliverable as @deliverable" do
      get(:edit, { mission_id: @mission.id, id: @deliverable.to_param })
      expect(assigns(:deliverable)).to eq(@deliverable)
    end

    it "allows anyone for unowned missions" do
      get(:edit, { mission_id: @mission.id, id: @deliverable.to_param })
      expect(response).to be_ok
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        get(:edit, { mission_id: @mission.id, id: @deliverable.to_param })
        expect(response).to be_ok
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        get(:edit, { mission_id: @mission.id, id: @deliverable.to_param })
        expect(response).to redirect_to(auth_path)
      end
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        get(:edit, { mission_id: @mission.id, id: @deliverable.to_param })
        expect(response.status).to eq(403)
      end
    end
  end

  describe "POST #create" do
    it "creates a new Deliverable for mission" do
      attributes = {
        name: Faker::Name.name,
        value: Faker::Lorem.sentence
      }
      expect {
        post(:create, {
          mission_id: @mission.id,
          deliverable: attributes
        })
      }.to change(Deliverable, :count).by(1)
      created_attributes = latest_deliverable.attributes
      attributes.stringify_keys.each do |(field, value)|
        expect(created_attributes.fetch(field)).to eq(value)
      end
    end

    it "defaults ordering to last" do
      first_deliverable = Generator.deliverable!
      attributes = Generator.deliverable({ mission: first_deliverable.mission }).attributes
      post(:create, { mission_id: first_deliverable.mission.id, deliverable: attributes })
      expect(latest_deliverable.ordering).to eq(1)
    end

    it "redirects back to mission" do
      post(:create, { mission_id: @mission.id, deliverable: Generator.deliverable.attributes })
      expect(response).to redirect_to(mission_path(@mission, {
        anchor: latest_deliverable.to_param
      }))
    end

    it "re-renders the 'new' template on error" do
      post(:create, { mission_id: @mission.id, deliverable: { name: nil } })
      expect(assigns(:deliverable)).to be_a_new(Deliverable)
      expect(response).to render_template("new")
    end

    it "allows anyone for unowned missions" do
      expect {
        post(:create, { mission_id: @mission.id, deliverable: Generator.deliverable.attributes })
      }.to change { Deliverable.count }.by(1)
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        expect {
          post(:create, { mission_id: @mission.id, deliverable: Generator.deliverable.attributes })
        }.to change { Deliverable.count }.by(1)
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        expect {
          post(:create, { mission_id: @mission.id, deliverable: Generator.deliverable.attributes })
        }.to change { Deliverable.count }.by(0)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        expect {
          post(:create, { mission_id: @mission.id, deliverable: Generator.deliverable.attributes })
        }.to change { Deliverable.count }.by(0)
      end
      expect(response.status).to eq(403)
    end
  end

  describe "PUT #update" do
    it "updates the requested deliverable" do
      new_data = {
        name: Faker::Name.name,
        value: Faker::Lorem.sentence
      }

      put(:update, {
        mission_id: @mission.id,
        id: @deliverable.to_param,
        deliverable: new_data
      })

      expect(@deliverable.reload.attributes).to include(new_data.stringify_keys)
    end

    it "redirects to the deliverable" do
      put(:update, {
        mission_id: @mission.id,
        id: @deliverable.to_param,
        deliverable: {
          name: Faker::Name.name
        }
      })
      expect(response).to redirect_to(mission_path(@deliverable.mission, {
        anchor: latest_deliverable.to_param
      }))
    end

    it "re-renders the 'edit' template on error" do
      put(:update, {
        mission_id: @mission.id,
        id: @deliverable.to_param,
        deliverable: {
          name: nil
        }
      })
      expect(assigns(:deliverable)).to eq(@deliverable)
      expect(response).to render_template("edit")
    end

    it "allows anyone for unowned missions" do
      new_data = { name: Faker::Name.name }
      put(:update, { mission_id: @mission.id, id: @deliverable.to_param, deliverable: new_data })
      expect(@deliverable.reload.attributes).to include(new_data.stringify_keys)
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        new_data = { name: Faker::Name.name }
        put(:update, { mission_id: @mission.id, id: @deliverable.to_param, deliverable: new_data })
        expect(@deliverable.reload.attributes).to include(new_data.stringify_keys)
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        new_data = { name: Faker::Name.name }
        put(:update, { mission_id: @mission.id, id: @deliverable.to_param, deliverable: new_data })
        expect(@deliverable.reload.attributes).to_not include(new_data.stringify_keys)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        new_data = { name: Faker::Name.name }
        put(:update, { mission_id: @mission.id, id: @deliverable.to_param, deliverable: new_data })
        expect(@deliverable.reload.attributes).to_not include(new_data.stringify_keys)
      end
      expect(response.status).to eq(403)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested deliverable" do
      expect {
        delete(:destroy, { mission_id: @mission.id, id: @deliverable.to_param })
      }.to change(Deliverable, :count).by(-1)
    end

    it "destroys requirements" do
      deliverable = Generator.deliverable!
      2.times { Generator.requirement!({ deliverable: deliverable }) }
      expect {
        delete(:destroy, { mission_id: @mission.to_param, id: deliverable.to_param })
      }.to change(Requirement, :count).by(-2)
    end

    it "redirects to the deliverables list" do
      delete(:destroy, { mission_id: @mission.id, id: @deliverable.to_param })
      expect(response).to redirect_to(mission_path(@deliverable.mission))
    end

    it "allows anyone for unowned missions" do
      expect {
        delete(:destroy, { mission_id: @mission.id, id: @deliverable.to_param })
      }.to change(Deliverable, :count).by(-1)
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        expect {
          delete(:destroy, { mission_id: @mission.id, id: @deliverable.to_param })
        }.to change(Deliverable, :count).by(-1)
      end
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        expect {
          delete(:destroy, { mission_id: @mission.id, id: @deliverable.to_param })
        }.to change(Deliverable, :count).by(0)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        expect {
          delete(:destroy, { mission_id: @mission.id, id: @deliverable.to_param })
        }.to change(Deliverable, :count).by(0)
      end
      expect(response.status).to eq(403)
    end
  end

  describe "PUT order_requirements" do
    before(:each) do
      add_json_headers!
    end

    it "updates the order of the requirements" do
      first_requirement, second_requirement = 2.times.collect do |i|
        Requirement.create!({
          deliverable: @deliverable,
          name: Faker::Name.name,
          ordering: i
        })
      end

      put(:order_requirements, {
        mission_id: @mission.id,
        id: @deliverable.to_param,
        requirements: [{
          id: second_requirement.id
        }, {
          id: first_requirement.id
        }]
      })

      expect(response).to be_successful
      expect(first_requirement.reload.ordering).to eq(1)
      expect(second_requirement.reload.ordering).to eq(0)
    end

    it "will ensure requirement is now part of deliverable" do
      new_deliverable = Generator.deliverable!
      requirement = Requirement.create!({
        deliverable: @deliverable,
        name: Faker::Name.name
      })

      put(:order_requirements, {
        mission_id: @mission.id,
        id: new_deliverable.id,
        requirements: [{
          id: requirement.id
        }]
      })

      expect(response).to be_successful
      expect(requirement.reload.deliverable).to eq(new_deliverable)
    end

    it "allows anyone for unowned missions" do
      requirement = Generator.requirement!
      put(:order_requirements, {
        mission_id: @mission.id,
        id: @deliverable.to_param,
        requirements: [{ id: requirement.id }]
      })
      expect(response).to be_successful
    end

    it "allows participants of owned missions" do
      @mission.users << @participant
      login!(@participant) do
        requirement = Generator.requirement!
        put(:order_requirements, {
          mission_id: @mission.id,
          id: @deliverable.to_param,
          requirements: [{ id: requirement.id }]
        })
      end
      expect(response).to be_successful
    end

    it "does not allow anonymous users of owned missions" do
      @mission.users << @participant
      login! do
        requirement = Generator.requirement!
        put(:order_requirements, {
          mission_id: @mission.id,
          id: @deliverable.to_param,
          requirements: [{ id: requirement.id }]
        })
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants of owned missions" do
      @mission.users << @participant
      login!(@non_participant) do
        requirement = Generator.requirement!
        put(:order_requirements, {
          mission_id: @mission.id,
          id: @deliverable.to_param,
          requirements: [{ id: requirement.id }]
        })
      end
      expect(response.status).to eq(403)
    end
  end
end
