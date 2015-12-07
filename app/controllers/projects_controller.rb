class ProjectsController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    render json: Project.all
  end

  def show
    project = find_project!
    render json: project
  end

  def create
    project = Project.new(create_params)

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
      render_validation_errors(project.errors)
    end
  end

  def update
    project = find_project!
    project.update(update_params)

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
      render_validation_errors(project.errors)
    end
  end

  private

    def create_params
      permitted_params.merge(owner: find_member!)
    end

    def update_params
      permitted_params
    end

    def permitted_params
      record_attributes.permit(:base_64_icon_data, :title, :description)
    end

    def member_slug
      params[:member_id]
    end

    def project_slug
      params[:id]
    end

    def find_project!
      member = find_member!
      Project.find_by!(slug: project_slug, owner: member.model)
    end

    def find_member!
      Member.find_by_slug!(member_slug)
    end
end
