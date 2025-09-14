class CreateProjectBullets < ActiveRecord::Migration[8.0]
  def change
    create_table :project_bullets do |t|
      t.text :content
      t.integer :position
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
