class AddUniqueIndexToLikes < ActiveRecord::Migration[7.1]
  def change
    add_index :likes, [:user_id, :likeable_id, :likeable_type], unique: true, name: 'unique_user_like'
  end
end
