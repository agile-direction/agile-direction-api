require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include APIHelpers

  describe "GET #index" do
    before(:all) do
      @geoff = Generator.user!({ name: "geoff" })
      @ashish = Generator.user!({ name: "ashish" })
    end

    before(:each) do
      add_json_headers!
    end

    it "returns users" do
      get(:index)
      user_ids = json_response.collect { |response| response["id"] }
      [@geoff, @ashish].each do |user|
        expect(user_ids).to include(user.id)
      end
    end

    it "returns users for term" do
      get(:index, { term: "ash" })
      expect(json_response.size).to eq(1)
    end

    it "returns users for term despite case" do
      get(:index, { term: "AsH" })
      expect(json_response.size).to eq(1)
    end

    it "maxes results to 5" do
      4.times { Generator.user! }
      get(:index)
      expect(json_response.size).to eq(5)
    end
  end

  describe "#show" do
    before(:each) do
      @user = Generator.user!
    end

    it "redirects if there is no current user" do
      get(:show, { id: @user.id })
      expect(response).to redirect_to(auth_path)
    end

    it "loads user" do
      controller.current_user = @user
      get(:show, { id: @user.id })
      expect(assigns(:user)).to eq(@user)
      expect(response.status).to eq(200)
    end

    it "does not let people see other users" do
      other_user = Generator.user!
      controller.current_user = @user

      get(:show, { id: other_user.id })
      expect(response.status).to eq(403)
    end
  end
end
