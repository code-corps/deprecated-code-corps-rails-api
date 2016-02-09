class AddBodyPreviewMarkdownPreviewToComments < ActiveRecord::Migration
  def change
    add_column :comments, :body_preview, :text, null: true
    add_column :comments, :markdown_preview, :text, null: true
    change_column_null :comments, :body, true
    change_column_null :comments, :markdown, true
  end
end
