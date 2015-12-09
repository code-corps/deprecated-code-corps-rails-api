class AllowSkippingNumberOnPosts < ActiveRecord::Migration
  def up
    change_column :posts, :number, :integer, null: true
    remove_index :posts, [:number, :project_id]
  end

  def down
    change_column :posts, :number, :integer, null: false
    add_index :posts, [:number, :project_id], unique: true
  end
end
