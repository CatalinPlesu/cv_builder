class ChangeDateToStartEndDateInProjects < ActiveRecord::Migration[8.0]
  def up
    add_column :projects, :start_date, :date
    add_column :projects, :end_date, :date
    remove_column :projects, :date
  end

  def down
    add_column :projects, :date, :string
    remove_column :projects, :start_date
    remove_column :projects, :end_date
  end
end
