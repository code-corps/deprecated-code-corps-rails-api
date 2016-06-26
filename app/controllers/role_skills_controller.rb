# == Schema Information
#
# Table name: role_skills
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cat        :integer
#

class RoleSkillsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    role_skill = RoleSkill.new(create_params)

    authorize role_skill

    if role_skill.valid?
      role_skill.save!
      render json: role_skill, include: [:role, :skill]
    else
      render_validation_errors role_skill.errors
    end
  end

  private

    def create_params
      parse_params(params, only: [:role, :skill])
    end
end
