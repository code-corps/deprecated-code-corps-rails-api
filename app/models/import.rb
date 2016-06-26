class Import < ActiveRecord::Base
  has_attached_file :file
  validates_attachment_file_name :file, matches: [/\.csv\Z/]

  enum status: [:unprocessed, :processed]

  after_create :perform!

  private

    def perform!
      PerformImportWorker.perform_async(id)
    end
end
