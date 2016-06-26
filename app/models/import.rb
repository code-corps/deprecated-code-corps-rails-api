# == Schema Information
#
# Table name: imports
#
#  id                :integer          not null, primary key
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  status            :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Import < ActiveRecord::Base
  has_attached_file :file,
                    path: "imports/:id/:style.:extension"

  validates_attachment_file_name :file, matches: [/\.csv\Z/]
  validates_attachment_content_type :file, content_type: %r{^text\/(csv|plain)}

  enum status: [:unprocessed, :processed, :failed]

  after_create :perform!

  private

    def perform!
      PerformImportWorker.perform_async(id)
    end
end
