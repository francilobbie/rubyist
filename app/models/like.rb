class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type], message: "can only like once" }

  after_create_commit :notify_like

  private


  def notify_like
    LikeNotification.with(
      message: "#{user.full_name} liked your #{likeable_type.downcase}",
      url: likeable_url(likeable)
    ).deliver_later(likeable.user) if likeable.user != user
  end

  def likeable_url(likeable)
    case likeable
    when Post
      Rails.application.routes.url_helpers.post_path(likeable)
    when Comment
      Rails.application.routes.url_helpers.post_path(likeable.post, anchor: "comment-#{likeable.id}")
    else
      root_path
    end
  end

end
