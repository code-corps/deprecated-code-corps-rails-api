class AddIconColumnsToProjects < ActiveRecord::Migration
  def up
      add_attachment :projects, :icon
    end

  def down
    remove_attachment :projects, :icon
  end
end
