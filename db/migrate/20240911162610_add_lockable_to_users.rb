class AddLockableToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :failed_attempts, :integer, default: 0, null: false # Only if lock strategy is :failed_attempts
    add_column :users, :unlock_token, :string

    add_index :users, :unlock_token, unique: true
  end
end
