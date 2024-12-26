class Feedback < ApplicationRecord
  belongs_to :user

  validates :name, :content, :category, presence: true
end
