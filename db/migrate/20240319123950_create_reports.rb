class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :reportable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
