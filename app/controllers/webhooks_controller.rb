# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV['STRIPE_ENDPOINT_SECRET']
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Handle the event
    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      handle_successful_payment(session)
    end

    render json: { message: 'success' }, status: :ok
  end

  private

  def handle_successful_payment(session)
    # You can handle the successful payment here (e.g., update your donation record)
  end
end
