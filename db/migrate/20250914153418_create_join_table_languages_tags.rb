class CreateJoinTableLanguagesTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :languages, :tags do |t|
      t.index [ :language_id, :tag_id ]
      t.index [ :tag_id, :language_id ]
    end
  end
end
