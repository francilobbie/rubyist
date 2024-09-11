class AddLockedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :locked_at, :datetime
  end
end
