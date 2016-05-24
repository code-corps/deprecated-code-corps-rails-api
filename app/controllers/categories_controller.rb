class CategoriesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def index
    authorize Category
    render json: Category.all
  end

  def show
    category = Category.find(params[:id])

    authorize category

    render json: category
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
