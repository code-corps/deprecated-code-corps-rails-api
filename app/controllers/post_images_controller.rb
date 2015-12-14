class PostImagesController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:create]

  def create
    post_image = PostImage.new(create_params)

    # authorize post_image

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
