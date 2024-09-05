# To deliver this notification:
#
# LikeNotification.with(post: @post).deliver_later(current_user)
# LikeNotification.with(post: @post).deliver(current_user)

class LikeNotification < Noticed::Base
  deliver_by :database
  deliver_by :action_cable, format: :to_action_cable

  param :message, :url

  def to_database
    {
      message: params[:message],
      url: params[:url]
    }
  end

  def to_action_cable
    {
      title: "New Like",
      message: params[:message],
      url: params[:url]
    }
  end

  private

  # Generate the correct URL based on whether the like is on a post or a comment
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
