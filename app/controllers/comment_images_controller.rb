class CommentImagesController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:create]

  def create
    comment_image = CommentImage.new(create_params)

    # authorize comment_image

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
