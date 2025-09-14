class CreateExperiences < ActiveRecord::Migration[8.0]
  def change
    create_table :experiences do |t|
      t.string :company
      t.string :location
      t.string :position_title
      t.date :start_date
      t.date :end_date
      t.boolean :current
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
