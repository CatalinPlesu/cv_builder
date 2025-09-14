class CreateExperienceBullets < ActiveRecord::Migration[8.0]
  def change
    create_table :experience_bullets do |t|
      t.text :content
      t.integer :position
      t.references :experience, null: false, foreign_key: true

      t.timestamps
    end
  end
end
