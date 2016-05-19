# == Schema Information
#
# Table name: post_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string           default("preview"), not null
#

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
