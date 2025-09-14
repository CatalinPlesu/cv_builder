class CreateCvHeadings < ActiveRecord::Migration[8.0]
  def change
    create_table :cv_headings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name

      t.timestamps
    end
  end
end
