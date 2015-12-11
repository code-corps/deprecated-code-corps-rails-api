class OrganizationsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def show
    organization = Organization.find(params[:id])

    authorize organization

    render json: organization
  end

  def create
    authorize Organization

    organization = Organization.new(create_params)

    if organization.valid?
      organization.save!
      render json: organization
    else
      render_validation_errors organization.errors
    end
  end

  private
    def create_params
      record_attributes.permit(:name)
    end
end
