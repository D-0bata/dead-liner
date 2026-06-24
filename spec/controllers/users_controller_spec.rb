require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "#current_or_guest_user" do
    it "responds successfully" do
      get :current_or_guest_user
      expect(response).to be_successful
    end

    it "returns a 200 response" do
      get :current_or_guest_user
      expect(response).to have_http_status "200"
    end
  end
end
