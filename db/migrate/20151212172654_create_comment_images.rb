class CreateCommentImages < ActiveRecord::Migration
  def change
    create_table :comment_images do |t|
      t.belongs_to :user, null: false
      t.belongs_to :comment, null: false

      t.text :filename, null: false
      t.text :base64_photo_data, null: false

      t.timestamps null: false
    end
  end
end
