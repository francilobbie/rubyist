class AddStripeCheckoutSessionIdToDonations < ActiveRecord::Migration[7.1]
  def change
    add_column :donations, :stripe_checkout_session_id, :string
  end
end
