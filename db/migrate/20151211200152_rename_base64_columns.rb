class RenameBase64Columns < ActiveRecord::Migration
  def change
    rename_column :post_images, :base_64_photo_data, :base64_photo_data
    rename_column :users, :base_64_photo_data, :base64_photo_data
    rename_column :projects, :base_64_icon_data, :base64_icon_data
  end
end
