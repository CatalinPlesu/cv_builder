class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :role
      t.date :start_date
      t.date :end_date
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
