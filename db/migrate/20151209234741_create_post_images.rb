class CreatePostImages < ActiveRecord::Migration
  def change
    create_table :post_images do |t|
      t.belongs_to :user, null: false
      t.belongs_to :post, null: false

      t.text :filename, null: false
      t.text :base_64_photo_data, null: false

      t.timestamps null: false
    end
  end
end
