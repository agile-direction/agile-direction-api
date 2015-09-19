require 'rails_helper'

RSpec.describe(OmniauthController, { type: :controller }) do
  before(:each) do
    @uid = rand(1...100)
  end

  let(:twitter_user) { User.find_by({ source_id: @uid }) }

  def set_auth_environment!(data)
    request.env["omniauth.auth"] = Remote::OAuth.twitter_response(data)
  end

  describe "GET #auth" do
    it "renders page" do
      get(:authenticate)
      expect(response.status).to eq(200)
    end
  end

  describe "PUT #logout" do
    it "logs user out" do
      user = User.create!({ name: Faker::Name.name })
      controller.current_user = user
      put(:logout)
      expect(controller.current_user).to eq(nil)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #callback" do
    it "creates user for twitter account" do
      set_auth_environment!({ uid: @uid })

      expect() {
        post(:callback)
      }.to change() {
        User.count
      }.by(1)

      expect(twitter_user).to be
    end

    it "sets current user" do
      set_auth_environment!({ uid: @uid })
      post(:callback)
      expect(controller.current_user).to eq(twitter_user)
    end

    it "redirects to users' page" do
      set_auth_environment!({ uid: @uid })
      post(:callback)
      expect(response).to redirect_to(user_path(controller.current_user))
    end

    it "redirects to original page user was trying to see" do
      mission = Generator.mission!
      session[:path_requiring_authentication] = mission_path(mission)
      set_auth_environment!({ uid: @uid })
      post(:callback)
      expect(response).to redirect_to(mission_path(mission))
    end

    it "upserts user for twitter account" do
      set_auth_environment!({ uid: @uid })

      expect() {
        post(:callback)
        post(:callback)
      }.to change() {
        User.count
      }.by(1)
    end

    it "displays fail screen if uid is not present in auth" do
      expect(Rails.logger).to receive(:error) do |error_arguments|
        expect(error_arguments[:error]).to match(/id/)
        expect(error_arguments[:userParams]).to include({ uid: nil })
      end

      set_auth_environment!({ uid: nil })

      expect() {
        post(:callback)
      }.to change() {
        User.count
      }.by(0)

      expect(response).to redirect_to("/auth/twitter/failure")
    end
  end

  describe "GET #failure" do
    it "returns bad request" do
      get(:failure)
      expect(response.status).to eq(400)
    end
  end
end
