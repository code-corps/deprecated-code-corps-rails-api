class SkillsController < ApplicationController
  def index
    authorize Skill
    render json: Skill.all.includes(:roles)
  end

  def create
    skill = Skill.new(permitted_params)

    authorize skill

    if skill.save
      render json: skill
    else
      render_validation_errors skill.errors
    end
  end

  private

    def permitted_params
      record_attributes.permit(:title)
    end
end
