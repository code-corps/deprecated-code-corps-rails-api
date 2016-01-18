# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  title              :string           not null
#  description        :string
#  owner_id           :integer
#  owner_type         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  icon_file_name     :string
#  icon_content_type  :string
#  icon_file_size     :integer
#  icon_updated_at    :datetime
#  base64_icon_data   :text
#  contributors_count :integer
#  slug               :string           not null
#

class ProjectsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    authorize Project

    if for_slugged_route?
      projects = find_projects_with_slugged_route!
    else
      projects = Project.all.includes(:contributors, :github_repositories)
    end

    render json: projects
  end

  def show
    project = find_project_with_slugged_route!

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
      #{ owner_id: owner_id, owner_type: owner_type }
      { owner: owner }
    end

    def owner
      owner_type.constantize.find(owner_id) if owner_type.present?
    end

    def owner_id
      record_relationships.fetch(:owner, {}).fetch(:data, {})[:id]
    end

    def owner_type
      record_relationships.fetch(:owner, {}).fetch(:data, {})[:type]
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

    def find_project_with_slugged_route!
      slugged_route = find_slugged_route!
      Project.includes(:contributors, :github_repositories).find_by!(slug: project_slug, owner: slugged_route.owner)
    end

    def find_projects_with_slugged_route!
      slugged_route = find_slugged_route!
      Project.includes(:contributors, :github_repositories).where(owner: slugged_route.owner)
    end

    def find_slugged_route!
      SluggedRoute.find_by_slug!(slugged_route_slug)
    end
end
