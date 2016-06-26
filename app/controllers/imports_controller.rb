# == Schema Information
#
# Table name: imports
#
#  id         :integer          not null, primary key
#  status     :integer
#  file       :attachment
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
