# == Schema Information
#
# Table name: skill_categories
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SkillCategoriesController < ApplicationController

  def index
    authorize SkillCategory
    render json: SkillCategory.all.includes(:skills)
  end
end
