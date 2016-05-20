# == Schema Information
#
# Table name: project_skills
#
#  id         :integer          not null, primary key
#  project_id :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectSkillsController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :require_params, only: [:create]

  def create
    project_skill = ProjectSkill.new(create_params)

    if project_skill.project.blank?
      project_skill.valid?
      render_validation_errors project_skill.errors
      return
    end

    authorize project_skill

    if project_skill.valid?
      project_skill.save!
      render json: project_skill, include: [:skill, :project]
    else
      render_validation_errors project_skill.errors
    end
  end

  def destroy
    project_skill = ProjectSkill.find(params[:id])

    authorize project_skill

    project_skill.destroy!

    render json: :nothing, status: :no_content
  end

  private

    def require_params
      require_param :skill_id
      require_param :project_id
    end

    def create_params
      parse_params(params)
    end
end
