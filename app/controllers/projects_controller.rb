class ProjectsController < ApplicationController

  def index
    render json: Project.all
  end

  def show
    member = Member.find_by_slug(member_slug)
    project = Project.find_by!(slug: project_slug, owner: member.model)

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

  def member_slug
    params[:member_id]
  end

  def project_slug
    params[:id]
  end
end
