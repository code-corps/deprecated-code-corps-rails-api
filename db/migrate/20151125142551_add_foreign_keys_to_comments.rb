class AddForeignKeysToComments < ActiveRecord::Migration
  def change
    change_column :comments, :user_id, :integer, null: false
    add_foreign_key :comments, :users
    change_column :comments, :post_id, :integer, null: false
    add_foreign_key :comments, :posts
  end
end
