class AddRegionToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :region, :string
  end
end
