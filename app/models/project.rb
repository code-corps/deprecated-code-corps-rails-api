class Project < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  has_many :posts
  has_many :github_repositories

  has_attached_file :icon,
                    styles: {
                      large: "500x500#",
                      thumb: "100x100#"
                    },
                    path: "projects/:id/:style.:extension"

  before_validation :add_slug_if_blank

  validates :title, presence: true
  validates :slug, slug: true
  validate :slug_is_not_duplicate

  validates_presence_of :owner

  validates_attachment_content_type :icon,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates_attachment_size :icon, less_than: 10.megabytes


  def decode_image_data
    return unless base64_icon_data.present?
    data = StringIO.new(Base64.decode64(base64_icon_data))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = SecureRandom.hex + '.png'
    data.content_type = 'image/png'
    self.icon = data
  end

  private

    def slug_is_not_duplicate
      if Project.where.not(id: self.id).where(owner: self.owner).where('lower(slug) = ?', slug.try(:downcase)).present?
        errors.add(:slug, "has already been taken")
      end
    end

    def add_slug_if_blank
      unless self.slug.present?
        self.slug = self.title.try(:parameterize)
      end
    end
end
