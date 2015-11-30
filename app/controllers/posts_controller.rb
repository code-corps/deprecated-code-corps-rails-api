class PostsController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:create]

  def index
    posts = retrieve_page_for Post
    render json: posts
  end

  def show
    post = Post.find(params[:id])
    render json: post, include: ["comments"]
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
    def retrieve_page_for collection
      collection.limit(page_size).offset(offset)
    end

    def page_size
      params.fetch(:page, {}).fetch(:size, 10).to_i
    end

    def page_number
      params.fetch(:page, {}).fetch(:number, 0).to_i
    end

    def offset
      page_size * page_number
    end

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
