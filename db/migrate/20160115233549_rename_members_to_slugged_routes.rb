class RenameMembersToSluggedRoutes < ActiveRecord::Migration
  def up
    rename_table :members, :slugged_routes
  end

  def down
    rename_table :slugged_routes, :members
  end
end
