class CreateJoinTableExperienceBulletsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :experience_bullets, :tags do |t|
      t.index [ :experience_bullet_id, :tag_id ]
      t.index [ :tag_id, :experience_bullet_id ]
    end
  end
end
