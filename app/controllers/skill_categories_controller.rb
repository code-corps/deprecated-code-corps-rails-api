class SkillCategoriesController < ApplicationController

  def index
    authorize SkillCategory
    render json: SkillCategory.all.includes(:skills)
  end
end
