# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    # Stream notifications for the current user
    stream_from "notifications_#{current_user.id}_counter"
    stream_from "notifications_#{current_user.id}_list"
  end

  def unsubscribed
    # Any cleanup needed when the channel is unsubscribed
    stop_all_streams
  end
end
