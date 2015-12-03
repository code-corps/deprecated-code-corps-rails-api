class ProjectsController < ApplicationController

  def create
    project = Project.new(permitted_params)

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
      render_validation_errors(project.errors)
    end
  end

  def index
    projects = Project.all.includes(:github_repositories)
    render json: projects
  end

  def show
    project = Project.includes(:github_repositories).find(params[:id])
    render json: project, include: :github_repositories
  end

  def update
    project = Project.find(params[:id])
    project.update(permitted_params)

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
      render_validation_errors(project.errors)
    end
  end

  private

  def permitted_params
    record_attributes.permit(:base_64_icon_data, :title, :description)
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end
end
