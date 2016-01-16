class TeamProjectsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update, :show]

  def create
    team_project = TeamProject.new(create_params)

    authorize team_project

    if team_project.save
      render json: team_project
    else
      render_validation_errors team_project.errors
    end
  end

  def update
    team_project = TeamProject.find_by(id: params[:id])

    authorize team_project

    team_project.update(update_params)

    if team_project.save
      render json: team_project
    else
      render_validation_errors team_project.errors
    end
  end

  def show
    team_project = TeamProject.find_by(id: params[:id])

    authorize team_project

    render json: team_project
  end

  private

  def create_params
    record_attributes.permit(:team_id, :project_id, :role)
  end

  def update_params
    record_attributes.permit(:role)
  end
end