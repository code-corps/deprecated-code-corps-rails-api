class AllowNullOnPostTitle < ActiveRecord::Migration
  def change
    change_column_null :posts, :title, true
  end
end
