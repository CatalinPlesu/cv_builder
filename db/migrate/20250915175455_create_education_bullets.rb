class CreateEducationBullets < ActiveRecord::Migration[8.0]
  def change
    create_table :education_bullets do |t|
      t.text :content
      t.integer :position
      t.references :education, null: false, foreign_key: true

      t.timestamps
    end
  end
end
