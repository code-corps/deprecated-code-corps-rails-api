class AddAttachmentToCommentImages < ActiveRecord::Migration
  def up
    add_attachment :comment_images, :image
  end

  def down
    remove_attachment :comment_images, :image
  end
end
