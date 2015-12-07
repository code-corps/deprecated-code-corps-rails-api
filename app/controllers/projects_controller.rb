class ProjectsController < ApplicationController

  def index
    render json: Project.all
  end

  def show
    project = fetch_project!
    render json: project
  end

  def create
    project = Project.new(permitted_params)

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
      render_validation_errors(project.errors)
    end
  end

  def update
    project = fetch_project!
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

  def member_slug
    params[:member_id]
  end

  def project_slug
    params[:id]
  end

  def fetch_project!
    member = fetch_member!
    Project.find_by!(slug: project_slug, owner: member.model)
  end

  def fetch_member!
    Member.find_by_slug!(member_slug)
  end
end
