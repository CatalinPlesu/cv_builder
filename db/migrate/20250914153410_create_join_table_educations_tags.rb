class CreateJoinTableEducationsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :educations, :tags do |t|
      t.index [ :education_id, :tag_id ]
      t.index [ :tag_id, :education_id ]
    end
  end
end
