class ContributorsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def index
    authorize Contributor
    contributors = Contributor.where(filter_params).includes([:project, :user])
    render json: contributors, include: [:user, :project]
  end

  def create
    authorize Contributor
    contributor = Contributor.new(create_params)

    if contributor.valid?
      contributor.save!
      render json: contributor, include: [:user, :project]
    else
      render_validation_errors contributor.errors
    end
  end

  private
    def filter_params
      { project_id: params.require(:filter).require(:project_id) }
    end

    def create_params
      relationships
    end

    def relationships
      { project_id: project_id, user_id: user_id }
    end

    def project_id
      record_relationships.fetch(:project, {}).fetch(:data, {})[:id]
    end

    def user_id
      current_user.id
    end
end
