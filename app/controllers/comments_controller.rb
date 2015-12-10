class CommentsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def index
    comments = Comment.where(post: params[:post_id])
    render json: comments
  end

  def show
    comment = Comment.find(params[:id])
    render json: comment
  end

  def create
    authorize Comment
    comment = Comment.new(create_params)
    if comment.save
      GenerateCommentUserNotificationsWorker.perform_async(comment.id)
      render json: comment
    else
      render_validation_errors comment.errors
    end
  end

  private
    def create_params
      record_attributes.permit(:markdown).merge(relationships)
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
