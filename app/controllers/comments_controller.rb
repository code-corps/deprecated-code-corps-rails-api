class CommentsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def create
    authorize! :create, Comment
    comment = Comment.new(create_params)
    if comment.save
      render json: comment
    else
      render_validation_errors comment.errors
    end
  end

  private
    def create_params
      record_attributes.permit(:body).merge(relationships)
    end

    def post_id
      record_relationships.fetch(:post, {}).fetch(:data, {})[:id]
    end

    def user_id
      current_user.id
    end

    def relationships
      { post_id: post_id, user_id: user_id }
    end
end
