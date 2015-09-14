require "rails_helper"

RSpec.describe(ParticipantsController, { type: :controller }) do
  include APIHelpers

  before(:all) do
    @mission = Generator.mission!
    @geoff = Generator.user!
    @ashish = Generator.user!
  end

  describe "GET #new" do
    it "shows create form" do
      get(:new, { mission_id: @mission.id })
      expect(response).to render_template(:new)
    end

    it "shows form to everyone for unowned missions" do
      login! { get(:new, { mission_id: @mission.id }) }
      expect(response.status).to eq(200)
    end

    it "does not show form to anonymous users of owned missions" do
      @mission.users << @ashish
      login! { get(:new, { mission_id: @mission.id }) }
      expect(response).to redirect_to(auth_path)
    end

    it "shows form to participants of owned missions" do
      @mission.users << @ashish
      login!(@ashish) { get(:new, { mission_id: @mission.id }) }
      expect(response.status).to eq(200)
    end

    it "does not show form to non-participants of owned missions" do
      @mission.users << @ashish
      login!(@geoff) { get(:new, { mission_id: @mission.id }) }
      expect(response.status).to eq(403)
    end
  end

  describe "POST #create" do
    it "add user to mission" do
      expect {
        post(:create, {
          mission_id: @mission.id,
          participant: {
            user_id: @geoff.id
          }
        })
      }.to change { Participant.count }.by(1)
    end

    it "redirects do mission path" do
      post(:create, {
        mission_id: @mission.id,
        participant: {
          user_id: @geoff.id
        }
      })
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "allows anyone to create participant for unowned missions" do
      login! do
        expect {
          post(:create, {
            mission_id: @mission.id,
            participant: {
              user_id: @geoff.id
            }
          })
        }.to change { Participant.count }.by(1)
      end
    end

    it "allows participant to add another for owned missions" do
      @mission.users << @geoff
      login!(@geoff) do
        expect {
          post(:create, {
            mission_id: @mission.id,
            participant: {
              user_id: @ashish.id
            }
          })
        }.to change { Participant.count }.by(1)
      end
    end

    it "does not allow anonymous users to create participants for owned missions" do
      @mission.users << @geoff
      login! do
        expect {
          post(:create, {
            mission_id: @mission.id,
            participant: {
              user_id: @ashish.id
            }
          })
        }.to change { Participant.count }.by(0)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants to create participant for owned missions" do
      @mission.users << @geoff
      login!(@ashish) do
        expect {
          post(:create, {
            mission_id: @mission.id,
            participant: {
              user_id: @ashish.id
            }
          })
        }.to change { Participant.count }.by(0)
      end
      expect(response.status).to eq(403)
    end
  end

  describe "DELETE #destroy" do
    it "redirects to mission" do
      @mission.users << @ashish
      login!(@ashish) do
        delete(:destroy, {
          mission_id: @mission.id,
          id: @mission.participants.first.id
        })
      end
      expect(response).to redirect_to(mission_path(@mission))
    end

    it "removes user from mission" do
      ashish = Generator.user!
      @mission.users << @ashish
      expect {
        login!(@ashish) do
          delete(:destroy, {
            mission_id: @mission.id,
            id: Participant.find_by!({
              joinable_id: @mission.id,
              user_id: @ashish.id
            }).id
          })
        end
      }.to change { Participant.count }.by(-1)
      expect(@mission.reload.users).to_not include(@ashish)
    end

    it "allows participant to remove another for owned missions" do
      @mission.users << @geoff
      @mission.users << @ashish

      login!(@ashish) do
        expect {
          delete(:destroy, { mission_id: @mission.id, id: @mission.participants.first.id })
        }.to change { Participant.count }.by(-1)
      end
    end

    it "does not allow anonymous users to remove participants for owned missions" do
      @mission.users << @geoff
      login! do
        expect {
          delete(:destroy, { mission_id: @mission.id, id: @mission.participants.first.id })
        }.to change { Participant.count }.by(0)
      end
      expect(response).to redirect_to(auth_path)
    end

    it "does not allow non-participants to remove participant for owned missions" do
      @mission.users << @geoff
      login!(@ashish) do
        expect {
          delete(:destroy, { mission_id: @mission.id, id: @mission.participants.first.id })
        }.to change { Participant.count }.by(0)
      end
      expect(response.status).to eq(403)
    end
  end
end
