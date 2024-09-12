class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    event = nil

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400
      return
    end

    case event.type
    when 'charge.succeeded'
      handle_successful_charge(event.data.object)
    when 'charge.failed'
      handle_failed_charge(event.data.object)
    end

    render json: { message: 'Received' }, status: 200
  end

  private

  def handle_successful_charge(charge)
    donation = Donation.find_by(stripe_charge_id: charge.id)
    donation.update(status: 'succeeded') if donation
  end

  def handle_failed_charge(charge)
    donation = Donation.find_by(stripe_charge_id: charge.id)
    donation.update(status: 'failed') if donation
  end
end
