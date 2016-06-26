# == Schema Information
#
# Table name: skills
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  description  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  original_row :integer
#  slug         :string           not null
#

class SkillsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    if search_params.present?
      skills = Skill.includes(:roles).autocomplete(search_params)
    elsif coalesce?
      skills = Skill.includes(:roles).where(id: id_params)
    else
      skills = Skill.includes(:roles).all
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

    def coalesce?
      params.fetch(:filter, {})[:id].present?
    end

    def id_params
      params.require(:filter).require(:id).split(",")
    end

    def permitted_params
      parse_params(params, only: [:title])
    end

    def search_params
      params[:query]
    end
end
