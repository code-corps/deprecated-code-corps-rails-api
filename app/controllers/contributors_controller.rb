class ContributorsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def index
    contributors = Contributor.where(filter_params).includes([:project, :user])
    authorize contributors
    render json: contributors, include: [:user, :project]
  end

  def create
    contributor = Contributor.new(create_params)

    authorize contributor

    if contributor.valid?
      contributor.save!
      render json: contributor
    else
      render_validation_errors contributor.errors
    end
  end

  def update
    contributor = Contributor.find(params[:id])
    contributor.assign_attributes(update_params)
    # need to assign attributes, so we know what changed, since policy depends
    # on what specific changes are happening
    authorize contributor

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

    def update_params
      record_attributes.permit(:status)
    end
end
