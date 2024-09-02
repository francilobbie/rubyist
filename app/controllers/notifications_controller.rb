class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    respond_to do |format|
      format.html # Render the standard HTML view
      format.turbo_stream # Render the Turbo Stream view
    end
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("notification-dropdown-list", partial: "notifications/notification", locals: { notification: @notification }),
          turbo_stream.prepend("notification-index-list", partial: "notifications/notification", locals: { notification: @notification })
        ]
      end
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Notification deleted." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@notification)
      end
    end
  end
end
