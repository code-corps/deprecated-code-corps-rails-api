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

class ImportSerializer < ActiveModel::Serializer
  attributes :id, :file_name, :status

  def file_name
    @object.file_file_name
  end
end
