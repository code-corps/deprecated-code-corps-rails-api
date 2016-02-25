class AddBodyPreviewMarkdownPreviewToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :body_preview, :text, null: true
    add_column :posts, :markdown_preview, :text, null: true
    change_column_null :posts, :body, true
    change_column_null :posts, :markdown, true
  end
end
