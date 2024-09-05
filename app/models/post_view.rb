class PostView < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :post_id, presence: true
  validates :user_id, uniqueness: { scope: :post_id, message: "has already viewed this post" }, if: :user_present?

  private

  def user_present?
    user_id.present?
  end
end
