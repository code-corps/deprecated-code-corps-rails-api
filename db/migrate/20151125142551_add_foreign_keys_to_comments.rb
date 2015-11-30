class AddForeignKeysToComments < ActiveRecord::Migration
  def change
    change_column_null :comments, :user_id, false
    add_foreign_key :comments, :users
    change_column_null :comments, :post_id, false
    add_foreign_key :comments, :posts
  end
end
