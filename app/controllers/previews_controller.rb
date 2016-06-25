# == Schema Information
#
# Table name: previews
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  markdown   :text             not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PreviewsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def create
    preview = Preview.new(create_params)

    if preview.save
      render json: preview
    else
      render_validation_errors preview.errors
    end
  end

  private

    def create_params
      params_for_user(permitted_params)
    end

    def permitted_params
      parse_params(params, only: [:markdown])
    end
end
