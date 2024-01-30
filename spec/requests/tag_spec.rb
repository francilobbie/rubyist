require 'rails_helper'

RSpec.describe "Tags", type: :request do



  describe "DELETE /destroy" do
    let(:tag) { create(:tag) }
    it "it redirect to root_path" do
      delete tag_path(tag)
      expect(response).to redirect_to(root_path)
    end
  end
end
