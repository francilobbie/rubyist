class AddSuspensionCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :suspension_count, :integer, default: 0
  end
end
