class UserSkillsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    authorize UserSkill

    user_skill = UserSkill.new(create_params)

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
      relationships
    end

    def relationships
      { user_id: user_id, skill_id: skill_id }
    end

    def user_id
      current_user.id
    end

    def skill_id
      record_relationships.fetch(:skill, {}).fetch(:data, {})[:id]
    end
end
