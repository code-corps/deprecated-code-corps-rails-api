class CommentUserMentionsController < ApplicationController
  def index
    authorize CommentUserMention
    mentions = CommentUserMention.includes(:user, :comment).where(filter_params)
    render json: mentions
  end

  private

    def filter_params
      {
        comment_id: params[:comment_id],
        status: params[:status]
      }
    end
end
