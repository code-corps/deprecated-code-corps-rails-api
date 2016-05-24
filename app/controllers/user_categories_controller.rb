class UserCategoriesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :destroy]

  def show
    user_category = UserCategory.find(params[:id])

    authorize user_category

    render json: user_category
  end

  def create
    user_category = UserCategory.new(create_params)

    authorize user_category

    if user_category.valid?
      user_category.save!
      render json: user_category, include: [:user, :category]
    else
      render_validation_errors user_category.errors
    end
  end

  def destroy
    user_category = UserCategory.find(params[:id])

    authorize user_category

    user_category.destroy!

    render json: :nothing, status: :no_content
  end

  private

    def create_params
      params_for_user(
        parse_params(params, only: [:category])
      )
    end
end
