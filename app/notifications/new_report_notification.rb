class NewReportNotification < Noticed::Base
  deliver_by :database
  deliver_by :action_cable, format: :to_action_cable

  param :message, :url

  after_deliver :broadcast_notification

  def to_database
    {
      type: self.class.name,
      params: params.exect(:user),
      account: Current.account,
      user: recipient,
    }
  end

  def to_action_cable
    {
      title: "New Notification",
      message: params[:message],
      url: params[:url],
      id: record.id
    }
  end

  def url
    params[:url] || root_path
  end

  private

  def broadcast_notification
    # Broadcasting to the dropdown
    recipient.broadcast_prepend_later_to(
      "notifications_#{recipient.id}_dropdown_list",
      target: "notification-dropdown-list",
      partial: "notifications/notification",
      locals: { notification: self.record }
    )

    # Broadcasting to the index page
    recipient.broadcast_prepend_later_to(
      "notifications_#{recipient.id}_index_list",
      target: "notification-index-list",
      partial: "notifications/notification",
      locals: { notification: self.record }
    )

    # Broadcasting to the notification counter
    recipient.broadcast_replace_later_to(
      "notifications_#{recipient.id}_counter",
      target: "notification-counter",
      partial: "notifications/counter",
      locals: { user: recipient }
    )
  end


end
