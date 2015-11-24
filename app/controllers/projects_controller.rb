class ProjectsController < ApplicationController
  def index
    render json: Project.all
  end

  def show
    project = Project.find(params[:id])
    render json: project
  end
end
