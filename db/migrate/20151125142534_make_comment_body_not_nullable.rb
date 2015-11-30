class MakeCommentBodyNotNullable < ActiveRecord::Migration
  def change
    change_column_null :comments, :body, false
  end
end
