class CreateEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :educations do |t|
      t.string :institution
      t.string :location
      t.string :degree
      t.date :start_date
      t.date :end_date
      t.string :gpa
      t.text :additional_info
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
