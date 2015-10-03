require "rails_helper"

describe(ApplicationController, { type: :controller }) do
  include APIHelpers

  controller do
    before_filter(:require_user!)

    def index
      head(:ok)
    end
  end

  describe "#anchor_for" do
    it "returns anchor param with object's #to_param" do
      id = rand(10)
      object = double(:model, { to_param: id })
      expect(controller.anchor_for(object)).to eq({ anchor: "/#{id}" })
    end
  end

  describe "#require_user!" do
    it "does not redirect if there is a user" do
      login!(Generator.user!) do
        get(:index)
        expect(response).to be_ok
      end
    end

    it "redirects to auth page if there is no user" do
      login! do
        get(:index)
        expect(response).to redirect_to(auth_path)
      end
    end

    it "notifies user about need to login" do
      get(:index)
      expect(flash[:alert]).to match(/please login/i)
    end

    it "stores current location" do
      get(:index)
      expect(session[:path_requiring_authentication]).to eq("/anonymous")
    end
  end
end
