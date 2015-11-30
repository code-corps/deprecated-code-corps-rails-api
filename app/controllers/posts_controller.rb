class PostsController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:create]

  def index
    posts = Post.all.includes [:comments, :user, :project]
    render json: posts
  end

  def show
    post = Post.includes(comments: [:user]).find(params[:id])
    render json: post, include: [:comments]
  end

  def create
    authorize! :create, Post
    post = Post.new(create_params)
    if post.save
      render json: post
    else
      render_validation_errors post.errors
    end
  end

  private
    def create_params
      record_attributes.permit(:body, :title, :post_type).merge(relationships)
    end

    def project_id
      record_relationships.fetch(:project, {}).fetch(:data, {})[:id]
    end

    def user_id
      current_user.id
    end

    def relationships
      { project_id: project_id, user_id: user_id }
    end
end
