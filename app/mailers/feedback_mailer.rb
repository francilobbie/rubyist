class FeedbackMailer < ApplicationMailer
  default from: ENV['EMAIL_ADDRESS']

  # Admin notification email
  def notify_admin(feedback)
    @feedback = feedback
    @admin_emails = User.with_role(:admin).pluck(:email) # Assuming you're using a role system

    mail(to: @admin_emails, subject: "Nouveau retour soumis")
  end

  # User confirmation email
  def confirm_feedback_submission(feedback)
    @feedback = feedback
    mail(to: @feedback.user.email, subject: "Merci pour votre retour")
  end
end
