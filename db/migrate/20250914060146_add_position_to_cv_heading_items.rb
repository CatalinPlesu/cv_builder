class AddPositionToCvHeadingItems < ActiveRecord::Migration[8.0]
  def change
    add_column :cv_heading_items, :position, :integer
    add_index :cv_heading_items, [ :cv_heading_id, :position ]

    reversible do |dir|
      dir.up do
        CvHeading.find_each do |heading|
          heading.cv_heading_items.each_with_index do |item, index|
            item.update_column(:position, index + 1)
          end
        end
      end
    end
  end
end
