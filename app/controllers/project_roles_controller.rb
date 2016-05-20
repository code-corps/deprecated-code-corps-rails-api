class ProjectRolesController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :require_params, only: [:create]

  def create
    project_role = ProjectRole.new(create_params)

    if project_role.project.blank?
      project_role.valid?
      render_validation_errors project_role.errors
      return
    end

    authorize project_role

    if project_role.valid?
      project_role.save!
      render json: project_role, include: [:role, :project]
    else
      render_validation_errors project_role.errors
    end
  end

  def destroy
    project_role = ProjectRole.find(params[:id])

    authorize project_role

    project_role.destroy!

    render json: :nothing, status: :no_content
  end

  private

    def require_params
      require_param :role_id
      require_param :project_id
    end

    def create_params
      parse_params(params)
    end
end
