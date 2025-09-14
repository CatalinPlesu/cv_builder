class CreateJoinTableSkillsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :skills, :tags do |t|
      t.index [ :skill_id, :tag_id ]
      t.index [ :tag_id, :skill_id ]
    end
  end
end
