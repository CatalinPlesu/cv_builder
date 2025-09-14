class CreateJoinTableTagsTemplates < ActiveRecord::Migration[8.0]
  def change
    create_join_table :tags, :templates do |t|
      t.index [ :tag_id, :template_id ]
      t.index [ :template_id, :tag_id ]
    end
  end
end
