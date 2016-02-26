class PostUserMentionsController < ApplicationController
  def index
    authorize PostUserMention
    mentions = PostUserMention.includes(:user, :post).where(filter_params)
    render json: mentions
  end

  private

    def filter_params
      {
        post_id: params[:post_id],
        status: params[:status]
      }
    end
end
