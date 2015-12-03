class OrganizationsController < ApplicationController

  def show
    organization = Organization.find(params[:id])

    authorize organization, :show? # explicit show required by slug dispatcher

    render json: organization
  end
  
end
