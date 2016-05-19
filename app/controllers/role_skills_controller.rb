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
      relationships
    end

    def relationships
      { role_id: role_id, skill_id: skill_id }
    end

    def role_id
      record_relationships.fetch(:role, {}).fetch(:data, {})[:id]
    end

    def skill_id
      record_relationships.fetch(:skill, {}).fetch(:data, {})[:id]
    end
end
