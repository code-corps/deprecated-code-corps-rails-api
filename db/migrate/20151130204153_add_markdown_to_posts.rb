class AddMarkdownToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :markdown, :text, null: false
  end
end
