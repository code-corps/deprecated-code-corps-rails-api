# == Schema Information
#
# Table name: post_likes
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PostLikesController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    authorize PostLike

    post_like = PostLike.new(create_params)

    if post_like.valid?
      post_like.save!
      render json: post_like, include: [:user, :post]
    else
      render_validation_errors post_like.errors
    end
  end

  def destroy
    post_like = PostLike.find(params[:id])

    authorize post_like

    post_like.destroy!

    render json: :nothing, status: :no_content
  end

  private
    def create_params
      relationships
    end

    def relationships
      { user_id: user_id, post_id: post_id }
    end

    def user_id
      current_user.id
    end

    def post_id
      record_relationships.fetch(:post, {}).fetch(:data, {})[:id]
    end
end
