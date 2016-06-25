class RemovePreviewFieldsFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :body_preview, :string
    remove_column :posts, :markdown_preview, :string
  end
end
