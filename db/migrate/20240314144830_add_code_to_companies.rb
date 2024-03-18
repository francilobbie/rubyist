class AddCodeToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :code, :string
  end
end
