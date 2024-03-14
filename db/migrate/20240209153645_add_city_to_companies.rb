class AddCityToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :city, :string
  end
end
