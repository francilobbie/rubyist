# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  # default from: 'no-reply@yourapp.com'
  default from: ENV['EMAIL_ADDRESS']


  def new_report_notification
    @report = params[:report]
    Rails.logger.info "Sending email to: #{params[:recipient].email}"
    mail(to: params[:recipient].email, subject: "New Report Submitted")
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Captain Ruby!")
  end
end
