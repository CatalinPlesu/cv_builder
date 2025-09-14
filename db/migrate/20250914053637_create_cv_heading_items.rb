class CreateCvHeadingItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cv_heading_items do |t|
      t.references :cv_heading, null: false, foreign_key: true
      t.string :icon
      t.string :text
      t.string :url

      t.timestamps
    end
    add_index :cv_heading_items, :url
  end
end
