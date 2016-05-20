class ProjectCategoriesController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :require_params, only: [:create]

  def create
    project_category = ProjectCategory.new(create_params)

    if project_category.project.blank?
      project_category.valid?
      render_validation_errors project_category.errors
      return
    end

    authorize project_category

    if project_category.valid?
      project_category.save!
      render json: project_category, include: [:category, :project]
    else
      render_validation_errors project_category.errors
    end
  end

  def destroy
    project_category = ProjectCategory.find(params[:id])

    authorize project_category

    project_category.destroy!

    render json: :nothing, status: :no_content
  end

  private

    def require_params
      require_param :category_id
      require_param :project_id
    end

    def create_params
      parse_params(params)
    end
end
