class AddLinkTitleToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :link_title, :string
  end
end
