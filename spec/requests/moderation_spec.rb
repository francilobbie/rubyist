require 'rails_helper'

RSpec.describe "Moderations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/moderation/index"
      expect(response).to have_http_status(:success)
    end
  end

end
