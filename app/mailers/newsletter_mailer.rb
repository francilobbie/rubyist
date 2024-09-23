class NewsletterMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def new_article(post, subscriber_email)
    @post = post  # Use @post instead of @article
    @subscriber_email = subscriber_email  # Assign subscriber email to an instance variable
    mail(to: subscriber_email, subject: "Nouvel article : #{@post.title}")
  end

  def subscription_confirmation(subscriber_email)
    @subscriber_email = subscriber_email  # Assign subscriber email to an instance variable
    mail(to: subscriber_email, subject: "Confirmation d'inscription à la newsletter")
  end

  def unsubscription_confirmation(subscriber_email)
    @subscriber_email = subscriber_email  # Assign subscriber email to an instance variable
    mail(to: subscriber_email, subject: "Confirmation de désinscription de la newsletter")
  end
end
