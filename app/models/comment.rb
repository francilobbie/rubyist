class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validates :content, presence: true

  after_create_commit :custom_broadcast_append
  after_destroy_commit :custom_broadcast_remove
  after_update_commit :custom_broadcast_replace

  scope :top_level, -> { where(parent_id: nil) }

  private

  def custom_broadcast_append
    if parent_id.present?
      # Broadcast to the specific replies container for the parent comment
      target = "replies_for_comment_#{parent_id}"
    else
      # For top-level comments, broadcast to the general comments container
      target = "comments"
    end
    broadcast_append_later_to [post, :comments], target: target
  end

  def custom_broadcast_remove
    Turbo::StreamsChannel.broadcast_remove_to(
      [self.post, :comments],
      target: ActionView::RecordIdentifier.dom_id(self)
    )
  end



  def custom_broadcast_replace
    broadcast_replace_later_to [post, :comments]
  end
end
