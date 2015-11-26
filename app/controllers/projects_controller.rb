class ProjectsController < ApplicationController
  def create
    project = Project.new(permitted_params)

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
    end
  end

  def index
    render json: Project.all
  end

  def show
    project = Project.find(params[:id])
    render json: project
  end

  private

  def permitted_params
    record_attributes.permit(:base_64_icon_data, :title, :description)
  end
end
