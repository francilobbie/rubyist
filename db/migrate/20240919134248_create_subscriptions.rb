class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.boolean :subscribed

      t.timestamps
    end
  end
end
