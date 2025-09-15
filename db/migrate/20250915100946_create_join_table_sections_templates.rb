class CreateJoinTableSectionsTemplates < ActiveRecord::Migration[8.0]
  def change
    create_join_table :sections, :templates do |t|
      t.index [ :section_id, :template_id ]
      t.index [ :template_id, :section_id ]
    end
  end
end
