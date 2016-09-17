class MigrateImagesAndSluggedRoutesForPhoenix < ActiveRecord::Migration[5.0]
  def up
    add_column :organizations, :icon_string, :string
    add_column :projects, :icon_string, :string
    add_column :users, :photo_string, :string

    add_column :slugged_routes, :organization_id, :integer
    add_column :slugged_routes, :user_id, :integer

    Organization.all.each do |o|
      save_icon_string(o)
    end

    Project.all.each do |p|
      save_icon_string(p)
    end

    User.all.each do |u|
      save_photo_string(u)
    end

    SluggedRoute.all.each do |slugged_route|
      if slugged_route.owner_type == "Organization"
        slugged_route.organization_id = slugged_route.owner_id
      elsif slugged_route.owner_type == "User"
        slugged_route.user_id = slugged_route.owner_id
      end

      slugged_route.save
    end
  end

  def down
    remove_column :organizations, :icon_string
    remove_column :projects, :icon_string
    remove_column :users, :photo_string

    remove_column :slugged_routes, :organization_id
    remove_column :slugged_routes, :user_id
  end

  def save_icon_string(model)
    type = model.icon_content_type
    if !type.blank?
      type = type.split("/")[1]
      unless type == "png"
        type = ""
      end
      model.icon_string = "original.#{type}?#{model.icon_updated_at.to_i}"
      model.save
    end
  end

  def save_photo_string(model)
    type = model.photo_content_type
    if !type.blank?
      type = type.split("/")[1]
      unless type == "png"
        type = ""
      end
      model.photo_string = "original.#{type}?#{model.photo_updated_at.to_i}"
      model.save
    end
  end
end
