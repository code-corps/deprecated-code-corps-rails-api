# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  status           :string           default("open")
#  post_type        :string           default("task")
#  title            :string
#  body             :text
#  user_id          :integer          not null
#  project_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  post_likes_count :integer          default(0)
#  markdown         :text
#  number           :integer
#  aasm_state       :string
#  comments_count   :integer          default(0)
#

class PostsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    authorize Post
    posts = find_posts!
    render json: posts, meta: meta_for(post_count), each_serializer: PostSerializer
  end

  def show
    post = find_post!
    authorize post

    render json: post, include: [:comments, :post_user_mentions, :comment_user_mentions]
  end

  def create
    post = Post.new(create_params)

    authorize post

    if post.save
      post.reload
      GeneratePostUserNotificationsWorker.perform_async(post.id)
      render json: post
    else
      render_validation_errors post.errors
    end
  end

  def update
    post = Post.find(params[:id])

    authorize post

    post.assign_attributes(update_params)

    if post.save
      post.reload
      GeneratePostUserNotificationsWorker.perform_async(post.id)
      render json: post
    else
      render_validation_errors post.errors
    end
  end

  private

    def publish?
      true unless parse_params(params).fetch(:preview, false)
    end

    def update_params
      parse_params(params, only: [:markdown, :title, :post_type, :state])
    end

    def create_params
      params_for_user(
        parse_params(params, only: [:markdown, :title, :post_type, :project])
      )
    end

    def filter_params
      filter_params = {}
      filter_params[:post_type] = params[:post_type].split(",") if params[:post_type]
      filter_params[:status] = params[:status] if params[:status]
      filter_params
    end

    def project_id
      params[:project_id]
    end

    def post_id
      params[:id]
    end

    def find_project!
      Project.find(project_id)
    end

    def find_post!
      project = find_project!
      Post.includes(comments: :user).
        includes(:post_user_mentions, :comment_user_mentions).
        find_by!(project: project, number: post_id)
    end

    def find_posts!
      project = find_project!

      Post.
        includes(:user).
        includes(:project).
        includes(comments: :user).
        includes(:post_user_mentions).
        includes(:comment_user_mentions).
        where(filter_params.merge(project: project)).
        page(page_number).
        per(page_size)
    end

    def post_count
      Post.where(filter_params.merge(project_id: project_id)).count
    end
end
