class AddDepartmentCodeToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :department_code, :string
  end
end
