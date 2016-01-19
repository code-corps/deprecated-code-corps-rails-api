# == Schema Information
#
# Table name: comment_images
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  comment_id         :integer          not null
#  filename           :text             not null
#  base64_photo_data  :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class CommentImagesController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:create]

  def create
    comment_image = CommentImage.new(create_params)

    authorize comment_image

    if comment_image.save
      NotifyPusherOfCommentImageWorker.perform_async(comment_image.id)
      render json: comment_image
    else
      render_validation_errors comment_image.errors
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
      { comment_id: comment_id, user_id: user_id }
    end

    def comment_id
      record_relationships.fetch(:comment, {}).fetch(:data, {})[:id]
    end
end
