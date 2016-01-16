class RenameModelInSluggedRoutesToOwner < ActiveRecord::Migration
  def up
    rename_column :slugged_routes, :model_id, :owner_id
    rename_column :slugged_routes, :model_type, :owner_type
  end

  def down
    rename_column :slugged_routes, :owner_id, :model_id
    rename_column :slugged_routes, :owner_type, :model_type
  end
end
