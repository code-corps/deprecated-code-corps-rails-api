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
  before_action :doorkeeper_authorize!

  def index
    user_skills = UserSkill.where(user_id: current_user.id)

    authorize user_skills

    render json: user_skills
  end

  def create
    user_skill = UserSkill.new(create_params)

    authorize user_skill

    if user_skill.valid?
      user_skill.save!
      render json: user_skill, include: [:user, :skill]
    else
      render_validation_errors user_skill.errors
    end
  end

  def destroy
    user_skill = UserSkill.find(params[:id])

    authorize user_skill

    user_skill.destroy!

    render json: :nothing, status: :no_content
  end

  private

    def create_params
      params_for_user(
        parse_params(params, only: [:skill])
      )
    end

    def filter_user_id
      params[:filter][:user_id]
    end
end
