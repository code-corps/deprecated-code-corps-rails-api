class AddSlugToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :slug, :string
    Project.all.each do |project|
      project.update_attributes(slug: project.title.parameterize)
    end
    change_column_null :projects, :slug, false

    add_index :projects, :slug, :unique => true
  end
end
