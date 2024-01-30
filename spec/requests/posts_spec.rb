require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:post) { create(:post) }

  describe "GET /index" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_post_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get post_path(post)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      post = create(:post)
      get edit_post_path(post)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "redirects to root_path" do
      post posts_path, params: { post: attributes_for(:post) }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /update" do
    it "redirects to root_path" do
      patch post_path(post), params: { post: attributes_for(:post) }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /destroy" do
    it "redirects to root_path" do
      delete post_path(post)
      expect(response).to redirect_to(root_path)
    end
  end
end
