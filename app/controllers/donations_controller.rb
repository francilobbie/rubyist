# app/controllers/donations_controller.rb
class DonationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @donation = Donation.new
  end

  def create
    @donation = current_user.donations.build(donation_params)
    @donation.currency = 'eur'

    # Convert amount to cents for Stripe
    if @donation.amount.present?
      @donation.amount = (@donation.amount.to_f * 100).to_i
    end

    if params[:stripeToken].present?
      begin
        charge = Stripe::Charge.create(
          amount: @donation.amount,
          currency: @donation.currency,
          description: "Donation by #{current_user.email}",
          source: params[:stripeToken]
        )
        @donation.stripe_charge_id = charge.id
        @donation.status = charge.status
        if @donation.save
          redirect_to root_path, notice: 'Merci pour votre don! 🎉'
        else
          flash[:alert] = "😢 Il semble que ça n'a pas fonctionné. Veuillez réessayer."
          render :new
        end
      rescue Stripe::CardError => e
        flash[:alert] = e.message
        render :new
      end
    else
      flash[:alert] = '😢 Il semble que ça n\'a pas fonctionné. Veuillez réessayer.'
      render :new
    end
  end


  private

  def donation_params
    params.require(:donation).permit(:amount, :stripeToken)
  end
end
