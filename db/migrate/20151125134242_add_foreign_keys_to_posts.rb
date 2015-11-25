class AddForeignKeysToPosts < ActiveRecord::Migration
  def change
    change_column :posts, :user_id, :integer, null: false
    add_foreign_key :posts, :users
    change_column :posts, :project_id, :integer, null: false
    add_foreign_key :posts, :projects
  end
end
