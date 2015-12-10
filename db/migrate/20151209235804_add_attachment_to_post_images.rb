class AddAttachmentToPostImages < ActiveRecord::Migration
  def up
    add_attachment :post_images, :image
  end

  def down
    remove_attachment :post_images, :image
  end
end
