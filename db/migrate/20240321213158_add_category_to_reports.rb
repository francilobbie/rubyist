class AddCategoryToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :category, :string
  end
end
