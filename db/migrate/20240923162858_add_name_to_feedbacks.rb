class AddNameToFeedbacks < ActiveRecord::Migration[7.1]
  def change
    add_column :feedbacks, :name, :string
  end
end
