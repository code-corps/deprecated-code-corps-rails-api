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
      params_for_user(
        parse_params(params, only: [:post])
      )
    end
end
