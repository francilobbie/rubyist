# To deliver this notification:
#
# NewReportNotificationNotifier.with(record: @post, message: "New post").deliver(User.all)

# app/notifiers/new_report_notification_notifier.rb
class NewReportNotificationNotifier < Noticed::Event
  # Deliver via ActionCable for real-time updates
  deliver_by :action_cable do |config|
    config.channel = "NotificationsChannel"
    config.stream = -> { "notifications_#{recipient.id}" } # Ensure each user receives their notifications
    config.message = -> { message } # Provide the message
  end

  # Deliver via email
  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = :new_report_notification
  end

  # Define helper methods to be used in notifications
  notification_methods do
    def message
      "A new report has been submitted by #{params[:report].user.email}."
    end

    def url
      Rails.application.routes.url_helpers.report_path(params[:report])
    end
  end
end
