require 'rails_helper'

RSpec.describe("Mission API", { type: :request }) do
  describe("SHOW") do
    it 'returns a mission with all its attributes' do
      mission = Mission.create!(name: 'Some Mission', description: 'It will make us so much money')
      get "/api/v1/missions/#{mission.id}"
      expect(response).to be_success
      expect(json_body['mission']['id']).to eq(mission.id)
      expect(json_body['mission']['name']).to eq(mission.name)
      expect(json_body['mission']['description']).to eq(mission.description)
      expect(json_body['mission']['created_at']).to be
      expect(json_body['mission']['updated_at']).to be
    end

    it 'expands to return all its deliverables in order' do
      mission = Mission.create!(name: 'Some Mission', description: 'It will make us so much money')
      del1 = mission.deliverables.create!(name: 'Deliverable 1', value: 'desc 1', ordering: 3)
      del2 = mission.deliverables.create!(name: 'Deliverable 2', value: 'desc 2', ordering: 6)

      get "/api/v1/missions/#{mission.id}"
      expect(response).to be_success
      expect(json_body['mission']['deliverables']).to be
      expect(json_body['mission']['deliverables'].length).to be(mission.deliverables.count)
      expect(json_body['mission']['deliverables'][0]['name']).to eq(del1.name)
      expect(json_body['mission']['deliverables'][0]['value']).to eq(del1.value)
      expect(json_body['mission']['deliverables'][0]['ordering']).to eq(del1.ordering)
      expect(json_body['mission']['deliverables'][0]['created_at']).to be
      expect(json_body['mission']['deliverables'][0]['updated_at']).to be
    end

    it 'expands to return all its deliverables.requirements in order' do
      mission = Mission.create!(name: 'Some Mission', description: 'It will make us so much money')
      del1 = mission.deliverables.create!(name: 'Deliverable 1', value: 'desc 1')
      req2 = del1.requirements.create!(name: 'Requirement 2', description: 'desc 2', ordering: 3)
      req1 = del1.requirements.create!(name: 'Requirement 1', description: 'desc 1', ordering: 1)

      get "/api/v1/missions/#{mission.id}"
      expect(response).to be_success
      expect(json_body['mission']['deliverables'][0]['requirements']).to be
      expect(json_body['mission']['deliverables'][0]['requirements'][0]['name']).to eq(req1.name)
      expect(json_body['mission']['deliverables'][0]['requirements'][0]['description']).to eq(req1.description)
      expect(json_body['mission']['deliverables'][0]['requirements'][0]['ordering']).to eq(req1.ordering)
      expect(json_body['mission']['deliverables'][0]['requirements'][0]['created_at']).to be
      expect(json_body['mission']['deliverables'][0]['requirements'][0]['updated_at']).to be
    end

    it 'returns a 404 if no mission could be found' do
      get "/api/v1/missions/1000"
      expect(response).not_to be_success
      expect(response.code).to eq('404')
    end
  end

  describe("INDEX") do
    it("returns missions") do
      mission = Mission.create!({ name: 'Some Mission', description: 'It will make us so much money' })
      get("/api/v1/missions")
      expect(json_body['missions'].first.fetch("id")).to eq(mission.id)
    end

    it("returns them by when they were created") do
      first, second = 2.times.collect {
        Mission.create!({
          name: 'Some Mission',
          description: 'It will make us so much money'
        })
      }
      get("/api/v1/missions")
      expect(json_body['missions'].first.fetch("id")).to eq(second.id)
      expect(json_body['missions'].second.fetch("id")).to eq(first.id)
    end
  end
end
