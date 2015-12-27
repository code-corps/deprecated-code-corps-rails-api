class CommentImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  validates_presence_of :user
  validates_presence_of :comment
  validates_presence_of :filename
  validates_presence_of :base64_photo_data

  has_attached_file :image,
                    path: "comments/:comment_id/images/:id/:style.:extension"

  validates_attachment_content_type :image,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates :base64_photo_data, base64_photo_data: true

  validates_attachment_size :image, less_than: 10.megabytes

  def decode_image_data
    return unless base64_photo_data.present?
    data = Paperclip.io_adapters.for(base64_photo_data)
    data.original_filename = self.filename
    self.image = data
  end

  Paperclip.interpolates :comment_id do |attachment, style|
    attachment.instance.comment_id
  end
end
