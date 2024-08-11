class AddArchivedToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :archived, :boolean
  end
end
