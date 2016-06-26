# == Schema Information
#
# Table name: preview_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  preview_id  :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PreviewUserMentionsController < ApplicationController
  def index
    authorize PreviewUserMention
    mentions = PreviewUserMention.includes(:user, :preview).where(filter_params)
    render json: mentions
  end

  private

    def filter_params
      { preview_id: params[:preview_id] }
    end
end
