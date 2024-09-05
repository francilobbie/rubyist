# To deliver this notification:
#
# ReplyNotification.with(post: @post).deliver_later(current_user)
# ReplyNotification.with(post: @post).deliver(current_user)

class ReplyNotification < Noticed::Base
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
      title: "New Reply",
      message: params[:message],
      url: params[:url]
    }
  end

  def reply_url(comment)
    # Linking to the post page with an anchor to the specific reply
    Rails.application.routes.url_helpers.post_path(comment.post, anchor: "comment-#{comment.id}")
  end
end
