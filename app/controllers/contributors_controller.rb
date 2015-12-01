class ContributorsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def index
    authorize Contributor
    contributors = Contributor.where(filter_params).includes([:project, :user])
    render json: contributors, include: [:user, :project]
  end

  private
    def filter_params
      { project_id: project_id }
    end

    def project_id
      params.require(:filter).require(:project_id)
    end
end
