class RemoveAdditionalInfoFromEducations < ActiveRecord::Migration[8.0]
  def change
    remove_column :educations, :additional_info, :text
  end
end
