class UserSkillsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    user_skill = UserSkill.create(create_params)
    render json: user_skill
  end

  def destroy
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
