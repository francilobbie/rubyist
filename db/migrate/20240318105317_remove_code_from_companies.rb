class RemoveCodeFromCompanies < ActiveRecord::Migration[7.1]
  def change
    remove_column :companies, :code, :string # Change :string to the correct data type if different
  end
end
