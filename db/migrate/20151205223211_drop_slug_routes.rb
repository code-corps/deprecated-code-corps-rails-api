class DropSlugRoutes < ActiveRecord::Migration
  def change
    drop_table :slug_routes
  end
end
