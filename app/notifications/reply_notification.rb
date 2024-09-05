# To deliver this notification:
#
# ReplyNotification.with(post: @post).deliver_later(current_user)
# ReplyNotification.with(post: @post).deliver(current_user)

class ReplyNotification < Noticed::Base
  deliver_by :database
  deliver_by :action_cable, format: :to_action_cable

  param :message, :url

  after_deliver :broadcast_notification


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
      url: params[:url],
      id: record.id
    }
  end

  def reply_url(comment)
    # Linking to the post page with an anchor to the specific reply
    Rails.application.routes.url_helpers.post_path(comment.post, anchor: "comment-#{comment.id}")
  end

  private

  def broadcast_notification
    recipient.broadcast_prepend_later_to(
      "notifications_#{recipient.id}_dropdown_list",
      target: "notification-dropdown-list",
      partial: "notifications/notification",
      locals: { notification: self.record }
    )

    recipient.broadcast_replace_later_to(
      "notifications_#{recipient.id}_counter",
      target: "notification-counter",
      partial: "notifications/counter",
      locals: { user: recipient }
    )
  end
end
