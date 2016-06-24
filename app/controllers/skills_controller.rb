# == Schema Information
#
# Table name: skills
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SkillsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    if search_params.present?
      skills = Skill.includes(:roles).autocomplete(search_params)
    else
      skills = Skill.all.includes(:roles)
    end

    authorize Skill
    render json: skills
  end

  def show
    skill = Skill.find(params[:id])

    authorize skill

    render json: skill
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
      parse_params(params, only: [:title])
    end

    def search_params
      params[:query]
    end
end
