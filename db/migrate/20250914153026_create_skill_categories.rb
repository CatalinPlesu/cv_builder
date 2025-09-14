class CreateSkillCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :skill_categories do |t|
      t.string :name
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
