# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

class CategoriesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def index
    authorize Category
    render json: Category.all
  end

  def create
    category = Category.new(permitted_params)

    authorize category

    if category.save
      render json: category
    else
      render_validation_errors category.errors
    end
  end

  private

    def permitted_params
      record_attributes.permit(:name, :description)
    end
end
