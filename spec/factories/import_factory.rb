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

FactoryGirl.define do
  factory :import do
    status :unprocessed
    file { File.new(Rails.root.join("spec", "sample_data", "import.csv")) }
  end
end
