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

require "rails_helper"

describe Import, type: :model do
  describe "schema" do
    it { should have_db_column(:status).of_type(:integer) }
  end

  describe "paperclip" do
    it { should have_attached_file(:file) }
    it { should validate_attachment_content_type(:file).allowing("text/csv", "text/plain") }
  end

  describe "behavior" do
    it { should define_enum_for(:status).with([:unprocessed, :processed, :failed]) }
  end

  describe "after_create" do
    subject { create(:import) }

    it "calls perform method" do
      expect { subject }.to change(PerformImportWorker.jobs, :size).by(1)
    end
  end
end
