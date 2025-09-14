class CreateJoinTableReferencesTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :references, :tags do |t|
      t.index [ :reference_id, :tag_id ]
      t.index [ :tag_id, :reference_id ]
    end
  end
end
