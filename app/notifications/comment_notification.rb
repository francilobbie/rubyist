# To deliver this notification:
#
# CommentNotification.with(post: @post).deliver_later(current_user)
# CommentNotification.with(post: @post).deliver(current_user)

class CommentNotification < Noticed::Base
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
      title: "New Comment",
      message: params[:message],
      url: params[:url]
    }
  end

  def comment_url(comment)
    # Linking to the post page with an anchor to the specific comment
    Rails.application.routes.url_helpers.post_path(comment.post, anchor: "comment-#{comment.id}")
  end
end
