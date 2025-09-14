class CreateJoinTableExperiencesTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :experiences, :tags do |t|
      t.index [ :experience_id, :tag_id ]
      t.index [ :tag_id, :experience_id ]
    end
  end
end
