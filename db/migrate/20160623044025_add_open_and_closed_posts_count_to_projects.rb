class AddOpenAndClosedPostsCountToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :open_posts_count, :integer, null: false, default: 0
    add_column :projects, :closed_posts_count, :integer, null: false, default: 0
  end
end
