class AddLongDescriptionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :long_description_body, :text
    add_column :projects, :long_description_markdown, :text
  end
end
