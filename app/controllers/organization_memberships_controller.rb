class OrganizationMembershipsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update, :destroy]

  # /organizations/:id/memberships
  def index
    authorize organization_memberships
    render json: organization_memberships,
           meta: meta_for(organization_membership_count),
           each_serializer: OrganizationMembershipSerializer
  end

  def create
    organization_membership = OrganizationMembership.new(create_params)

    authorize organization_membership

    if organization_membership.save
      render json: organization_membership
    else
      render_validation_errors organization_membership.errors
    end
  end

  def update
    organization_membership = OrganizationMembership.find(params[:id])
    organization_membership.assign_attributes(update_params)

    authorize organization_membership

    if organization_membership.save
      render json: organization_membership
    else
      render_validation_errors organization_membership.errors
    end
  end

  def destroy
    organization_membership = OrganizationMembership.find(params[:id])
    authorize organization_membership
    organization_membership.destroy!
    render json: :nothing, status: :no_content
  end

  private

    # for index

    def filter_params
      filter_params = {}
      filter_params[:organization] = organization
      filter_params[:role] = params[:role] if params[:role]
      filter_params
    end

    def organization_memberships
      OrganizationMembership.
        includes(:member).
        includes(:organization).
        where(filter_params).
        page(page_number).
        per(page_size)
    end

    def organization_membership_count
      OrganizationMembership.where(filter_params).count
    end

    def organization
      Organization.find(params[:organization_id])
    end

    # for create and update

    def organization_id
      record_relationships.fetch(:organization, {}).fetch(:data, {})[:id]
    end

    def member_id
      record_relationships.fetch(:member, {}).fetch(:data, {})[:id]
    end

    def relationships
      { organization_id: organization_id, member_id: member_id }
    end

    def update_params
      record_attributes.permit(:role)
    end

    def create_params
      update_params.merge(relationships)
    end
end
