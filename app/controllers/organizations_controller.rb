class OrganizationsController < ApplicationController

  def show
    organization = Organization.find(params[:id])

    authorize Organization
    render json: organization
  end
  
end
