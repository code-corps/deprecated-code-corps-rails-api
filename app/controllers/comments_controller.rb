class CommentsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    authorize Comments

    comments = Comment.where(post: params[:post_id])
    render json: comments
  end

  def show
    comment = Comment.find(params[:id])

    authorize comment

    render json: comment
  end

  def create
    comment = Comment.new(create_params)
    authorize comment

    if comment.save
      GenerateCommentUserNotificationsWorker.perform_async(comment.id)
      render json: comment
    else
      render_validation_errors comment.errors
    end
  end

  def update
    comment = Comment.find(params[:id])

    authorize comment

    comment.assign_attributes(update_params)

    if comment.update!
      render json: comment
    else
      render_validation_errors comment.errors
    end
  end

  private
    def create_params
      record_attributes.permit(:markdown, :state).merge(relationships)
    end

    def update_params
      record_attributes.permit(:markdown, :state).merge(relationships)
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
