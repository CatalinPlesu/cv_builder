class CreateJoinTableCertificatesTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :certificates, :tags do |t|
      t.index [ :certificate_id, :tag_id ]
      t.index [ :tag_id, :certificate_id ]
    end
  end
end
