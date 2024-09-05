# To deliver this notification:
#
# MentionNotification.with(post: @post).deliver_later(current_user)
# MentionNotification.with(post: @post).deliver(current_user)

class MentionNotification < Noticed::Base
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
      title: "You've been mentioned",
      message: params[:message],
      url: params[:url],
      id: record.id
    }
  end

  def mention_url(mention)
    case mention.mentionable
    when Post
      Rails.application.routes.url_helpers.post_path(mention.mentionable)
    when Comment
      Rails.application.routes.url_helpers.post_path(mention.mentionable.post, anchor: "comment-#{mention.mentionable.id}")
    else
      root_path # Fallback if mentionable is not a post or comment
    end
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
