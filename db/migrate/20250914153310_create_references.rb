class CreateReferences < ActiveRecord::Migration[8.0]
  def change
    create_table :references do |t|
      t.string :name
      t.string :contact
      t.string :position_title
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
