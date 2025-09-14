class CreateJoinTableSkillCategoriesTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :skill_categories, :tags do |t|
      t.index [ :skill_category_id, :tag_id ]
      t.index [ :tag_id, :skill_category_id ]
    end
  end
end
