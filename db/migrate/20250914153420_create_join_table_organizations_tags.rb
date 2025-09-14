class CreateJoinTableOrganizationsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :organizations, :tags do |t|
      t.index [ :organization_id, :tag_id ]
      t.index [ :tag_id, :organization_id ]
    end
  end
end
