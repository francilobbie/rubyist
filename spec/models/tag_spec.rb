require 'rails_helper'

RSpec.describe Tag, type: :model do

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "associations" do
    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:posts).through(:taggings) }
  end
end
