class AddMarkdownToComments < ActiveRecord::Migration
  def change
    add_column :comments, :markdown, :text, null: false
  end
end
