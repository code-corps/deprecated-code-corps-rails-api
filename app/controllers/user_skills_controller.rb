# == Schema Information
#
# Table name: user_skills
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserSkillsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :destroy]

  def index
    authorize UserSkill

    if id_params.present?
      user_skills = UserSkill.includes(:skill, :user).where(id: id_params)
    elsif current_user.present?
      user_skills = UserSkill.includes(:skill, :user).where(user_id: current_user.id)
    else
      user_skills = []
    end

    render json: user_skills
  end

  def show
    user_skill = UserSkill.find(params[:id])

    authorize user_skill

    render json: user_skill
  end

  def create
    user_skill = UserSkill.new(create_params)

    authorize user_skill

    if user_skill.valid?
      user_skill.save!
      analytics.track_added_user_skill(user_skill)
      render json: user_skill, include: [:user, :skill]
    else
      render_validation_errors user_skill.errors
    end
  end

  def destroy
    user_skill = UserSkill.find(params[:id])

    authorize user_skill

    user_skill.destroy!

    analytics.track_removed_user_skill(user_skill)

    render json: :nothing, status: :no_content
  end

  private

    def create_params
      params_for_user(
        parse_params(params, only: [:skill])
      )
    end

    def id_params
      params.try(:fetch, :filter, nil).try(:fetch, :id, nil).try(:split, ",")
    end

    def filter_user_id
      params[:filter][:user_id]
    end
end
