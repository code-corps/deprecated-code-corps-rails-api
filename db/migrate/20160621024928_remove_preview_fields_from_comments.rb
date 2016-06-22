class RemovePreviewFieldsFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :body_preview, :string
    remove_column :comments, :markdown_preview, :string
  end
end
