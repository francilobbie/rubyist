class NewslettersController < ApplicationController
  before_action :authenticate_user!, only: [:subscribe, :unsubscribe]


  def subscribe_form
    @subscription = Subscription.find_by(email: params[:email]) || Subscription.new(email: params[:email])
    render :subscribe
  end

  def subscribe
    # Access the email directly from params[:email]
    email = params[:email]

    if Subscription.exists?(email: email)
      subscription = Subscription.find_by(email: email)
      if subscription.subscribed == false
        subscription.update(subscribed: true)
        NewsletterMailer.subscription_confirmation(email).deliver_later
        redirect_to root_path, notice: 'Merci pour votre inscription à notre newsletter !'
      else
        redirect_to root_path, alert: 'Vous êtes déjà inscrit à la newsletter.'
      end
    else
      subscription = Subscription.new(email: email, subscribed: true)

      if subscription.save
        NewsletterMailer.subscription_confirmation(email).deliver_later
        redirect_to root_path, notice: 'Merci pour votre inscription à notre newsletter !'
      else
        redirect_to root_path, alert: 'Il y a eu une erreur avec votre inscription. Veuillez réessayer.'
      end
    end
  end

  def confirm_unsubscribe
    @subscription = Subscription.find_by(email: params[:email])

    if @subscription.nil? || @subscription.subscribed == false
      redirect_to root_path, alert: 'Aucun abonnement trouvé pour cet e-mail.'
    end
  end

  def unsubscribe
    # Access the email directly from params[:email]
    email = params[:email]

    subscription = Subscription.find_by(email: email, subscribed: true)

    if subscription
      subscription.update(subscribed: false)
      NewsletterMailer.unsubscription_confirmation(email).deliver_later
      redirect_to root_path, notice: 'Vous vous êtes désinscrit avec succès de la newsletter.'
    else
      redirect_to root_path, alert: 'Email introuvable dans nos abonnements.'
    end
  end
end
