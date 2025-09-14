class CreateCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificates do |t|
      t.string :name
      t.string :organization
      t.string :date
      t.text :description
      t.integer :position
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
