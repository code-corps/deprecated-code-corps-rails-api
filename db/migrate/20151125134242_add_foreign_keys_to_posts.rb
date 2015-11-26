class AddForeignKeysToPosts < ActiveRecord::Migration
  def change
    change_column_null :posts, :user_id, false
    add_foreign_key :posts, :users
    change_column_null :posts, :project_id, false
    add_foreign_key :posts, :projects
  end
end
