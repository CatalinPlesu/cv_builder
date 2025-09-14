class CreateAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :achievements do |t|
      t.string :title
      t.text :description
      t.string :date
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
