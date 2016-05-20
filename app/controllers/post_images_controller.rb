# == Schema Information
#
# Table name: post_images
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  post_id            :integer          not null
#  filename           :text             not null
#  base64_photo_data  :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class PostImagesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def create
    post_image = PostImage.new(create_params)

    authorize post_image

    if post_image.save
      NotifyPusherOfPostImageWorker.perform_async(post_image.id)
      render json: post_image
    else
      render_validation_errors post_image.errors
    end
  end

  private

    def create_params
      record_attributes.permit(:filename, :base64_photo_data).merge(relationships)
    end

    def user_id
      current_user.id
    end

    def relationships
      { post_id: post_id, user_id: user_id }
    end

    def post_id
      record_relationships.fetch(:post, {}).fetch(:data, {})[:id]
    end
end
