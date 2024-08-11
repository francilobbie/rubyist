class AddArchivedToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :archived, :boolean
  end
end
