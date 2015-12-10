class PostImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates_presence_of :user
  validates_presence_of :post
  validates_presence_of :filename
  validates_presence_of :base_64_photo_data

  has_attached_file :image,
                    path: "posts/:post_id/images/:id/:style.:extension"

  validates_attachment_content_type :image,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  def file_name_without_extension
    File.basename(@filename)
  end

  def file_extension
    File.extname(@filename).delete(".")
  end

  def decode_image_data
    return unless base_64_photo_data.present?
    data = Paperclip.io_adapters.for(base_64_photo_data)
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = self.filename
    data.content_type = 'image/#{file_extension}'
    self.image = data
  end

  Paperclip.interpolates :post_id do |attachment, style|
    attachment.instance.post_id
  end
end
