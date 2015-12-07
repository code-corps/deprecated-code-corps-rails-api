class OrganizationsController < ApplicationController

  def show
    organization = Organization.find(params[:id])

    authorize organization

    render json: organization
  end

end
