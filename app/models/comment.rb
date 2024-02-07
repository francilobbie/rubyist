class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :content, presence: true
  after_create_commit -> { broadcast_append_to post }

end
