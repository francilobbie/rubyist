# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def new_report_notification
    @report = params[:report]
    mail(to: params[:recipient].email, subject: "New Report Submitted")
  end
end
