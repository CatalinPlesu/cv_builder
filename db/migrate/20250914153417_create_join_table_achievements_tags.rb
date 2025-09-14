class CreateJoinTableAchievementsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :achievements, :tags do |t|
      t.index [ :achievement_id, :tag_id ]
      t.index [ :tag_id, :achievement_id ]
    end
  end
end
