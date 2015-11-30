class Project < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  has_many :posts

  has_attached_file :icon,
                    styles: {
                      large: "500x500#", 
                      thumb: "100x100#"
                    },
                    path: "projects/:id/:style.:extension"
  
  validates :title, presence: true
  validates_attachment_content_type :icon,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  def decode_image_data
    return unless base_64_icon_data.present?
    data = StringIO.new(Base64.decode64(base_64_icon_data))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = SecureRandom.hex + '.png'
    data.content_type = 'image/png'
    self.icon = data
  end
end
