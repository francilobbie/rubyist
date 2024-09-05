class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  enum status: { pending: 'pending', reviewed: 'reviewed', closed: 'closed' }
  validates :category, presence: true, inclusion: { in: ['spam', 'abuse', 'harassment', 'inappropriate content', 'other'] }

  after_create :send_new_report_notification

  private


  def send_new_report_notification
      recipients = User.with_role(:admin).or(User.with_role(:moderator))

      recipients.each do |recipient|
        puts "Sending notification to: #{recipient.email}"
        NewReportNotification.with(
          message: "A new report was submitted by #{user.email}.",
          url: Rails.application.routes.url_helpers.report_path(self)
        ).deliver_later(recipient)
      end
  end
end
