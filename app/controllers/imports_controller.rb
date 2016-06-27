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

class ImportsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    import = Import.new(import_params)

    authorize import

    if import.save
      render json: import
    else
      render_validation_errors import.errors
    end
  end

  private

    def import_params
      params.require(:import).permit(:file)
    end
end
