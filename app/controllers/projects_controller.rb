class ProjectsController < ApplicationController
  def create
    project = Project.create( project_params )
    render json: project
  end

  def index
    render json: Project.all
  end

  def show
    project = Project.find(params[:id])
    render json: project
  end

  private

  def project_params
    params.require(:project).permit(:base_64_icon_data, :title, :description)
  end
end
