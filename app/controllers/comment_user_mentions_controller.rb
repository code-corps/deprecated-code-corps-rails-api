# == Schema Information
#
# Table name: comment_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  comment_id  :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string           default("preview"), not null
#

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
