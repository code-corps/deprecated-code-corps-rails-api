# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#  slug              :string           not null
#  organization_id   :integer          not null
#

class ProjectsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    authorize Project

    if for_slugged_route?
      projects = find_projects_with_slugged_route!
    else
      projects = Project.all.includes(:github_repositories, :organization)
    end

    render json: projects
  end

  def show
    if project_show?
      project = Project.find(params[:id])
    elsif for_slugged_route?
      project = find_project_with_slugged_route!
    end

    authorize project

    render json: project, include: :github_repositories
  end

  def create
    project = Project.new(create_params)

    authorize project

    if project.save
      AddProjectIconWorker.perform_async(project.id)
      render json: project
    else
      render_validation_errors(project.errors)
    end
  end

  def update
    project = Project.find(params[:id])

    authorize project

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
      permitted_params.merge(relationships)
    end

    def update_params
      permitted_params
    end

    def relationships
      { organization_id: organization_id }
    end

    def organization_id
      record_relationships.fetch(:organization, {}).fetch(:data, {})[:id]
    end

    def permitted_params
      record_attributes.permit(:base64_icon_data, :title, :description, :slug)
    end

    def slugged_route_slug
      params[:slugged_route_id]
    end

    def project_slug
      params[:id]
    end

    def for_slugged_route?
      slugged_route_slug.present?
    end

    def project_show?
      slugged_route_slug == "projects"
    end

    def find_project_with_slugged_route!
      slugged_route = find_slugged_route!
      Project.includes(:github_repositories, :organization).find_by!(slug: project_slug, organization: slugged_route.owner)
    end

    def find_projects_with_slugged_route!
      slugged_route = find_slugged_route!
      Project.includes(:github_repositories, :organization).where(organization: slugged_route.owner)
    end

    def find_slugged_route!
      SluggedRoute.find_by_slug!(slugged_route_slug)
    end
end
