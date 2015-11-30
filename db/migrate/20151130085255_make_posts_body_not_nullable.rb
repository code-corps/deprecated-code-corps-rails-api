class MakePostsBodyNotNullable < ActiveRecord::Migration
  def change
    change_column_null :posts, :body, false
  end
end
