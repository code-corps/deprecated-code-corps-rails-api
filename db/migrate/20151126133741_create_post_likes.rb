class CreatePostLikes < ActiveRecord::Migration
  def change
    create_table :post_likes do |t|
      t.belongs_to :post, counter_cache: true
      t.belongs_to :user

      t.timestamps null: false
    end

    add_column :posts, :post_likes_count, :integer
  end
end
