class AddSeriesToPosts < ActiveRecord::Migration[7.1]
  def change
    add_reference :posts, :series, null: true, foreign_key: true
  end
end
