class CreateJoinTableProjectBulletsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :project_bullets, :tags do |t|
      t.index [ :project_bullet_id, :tag_id ]
      t.index [ :tag_id, :project_bullet_id ]
    end
  end
end
