require 'rails_helper'

RSpec.describe Post, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'associations' do
    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:tags).through(:taggings).dependent(:destroy) }
    it { should belong_to(:user) }
  end
end
