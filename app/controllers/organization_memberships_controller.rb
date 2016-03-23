class OrganizationMembershipsController < ApplicationController
  def index
    render json: organization_memberships,
           meta: meta_for(organization_membership_count),
           each_serializer: OrganizationMembershipSerializer
  end

  def create
  end

  def update
  end

  private

    def filter_params
      filter_params = {}
      filter_params[:organization] = organization
      filter_params[:role] = params[:role] if params[:role]
      filter_params
    end

    def organization_memberships
      pp params
      OrganizationMembership
        .includes(:member)
        .includes(:organization)
        .where(filter_params)
        .page(page_number)
        .per(page_size)
    end

    def organization_membership_count
      OrganizationMembership.where(filter_params).count
    end

    def organization
      Organization.find(params[:organization_id])
    end
end
