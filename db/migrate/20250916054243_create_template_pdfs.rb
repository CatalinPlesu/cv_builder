class CreateTemplatePdfs < ActiveRecord::Migration[8.0]
  def change
    create_table :template_pdfs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.string :status
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
