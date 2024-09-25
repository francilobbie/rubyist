class DonationsController < ApplicationController
  before_action :authenticate_user!, only: [ :create]

  def new
    @donation = Donation.new
  end

  def create
    @donation = current_user.donations.build(donation_params)
    @donation.currency = 'eur'

    # Convert amount to cents for Stripe
    if @donation.amount.present?
      @donation.amount = (@donation.amount.to_f * 100).to_i
      @donation.status = 'En attente' # Set status to 'pending' when the donation is initiated
    end

    # Create a Stripe Checkout session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card', 'link', 'paypal'],
      line_items: [{
        price_data: {
          currency: 'eur',
          product_data: {
            name: 'Donation',
          },
          unit_amount: @donation.amount,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: success_donations_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_donations_url
    )

    # Save the session ID for tracking
    @donation.stripe_checkout_session_id = session.id
    @donation.save

    # Redirect to the Stripe Checkout page
    redirect_to session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    session = Stripe::Checkout::Session.retrieve(session_id)

    @donation = Donation.find_by(stripe_checkout_session_id: session_id)

    if session.payment_status == 'paid'
      @donation.update(status: 'Envoyé avec succès') # Mark donation as 'completed' after successful payment
    end

    redirect_to root_path, notice: "Merci pour votre don!"
  end

  def cancel
    session_id = params[:session_id]
    @donation = Donation.find_by(stripe_checkout_session_id: session_id)
    @donation.update(status: 'Annulé') # Mark donation as 'cancelled' after payment is cancelled

    redirect_to root_path, alert: "Le paiement a été annulé."
  end

  private

  def donation_params
    params.require(:donation).permit(:amount)
  end
end
