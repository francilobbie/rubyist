class AddReportCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :report_count, :integer, default: 0
  end
end
