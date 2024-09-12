class CreateDonations < ActiveRecord::Migration[7.1]
  def change
    create_table :donations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount
      t.string :stripe_charge_id
      t.string :currency
      t.string :status

      t.timestamps
    end
  end
end
