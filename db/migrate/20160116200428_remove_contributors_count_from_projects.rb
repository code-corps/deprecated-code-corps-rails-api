class RemoveContributorsCountFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :contributors_count
  end

  def down
    add_column :projects, :contributors_count
  end
end
