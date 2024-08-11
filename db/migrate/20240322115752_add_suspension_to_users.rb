class AddSuspensionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :suspended_until, :datetime
    add_column :users, :suspended, :boolean
  end
end
