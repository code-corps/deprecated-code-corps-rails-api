class ApplicationController < ActionController::API
  include Clearance::Controller
  include Pundit

  before_action :set_default_response_format

  rescue_from Pundit::NotAuthorizedError, with: :render_error
  rescue_from ActionController::ParameterMissing, with: :render_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_error
  rescue_from ActionController::RoutingError, with: :render_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_error

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: ErrorSerializer.serialize(error) }
  end

  def signed_in?
    current_user.present?
  end

  def signed_out?
    current_user.nil?
  end

  def current_user
    current_resource_owner
  end

  def page_size
    params.fetch(:page, {}).fetch(:size, 10).to_i
  end

  def page_number
    params.fetch(:page, {}).fetch(:number, 1).to_i
  end

  def meta_for object
    return {
      total_records: object.count,
      total_pages: (object.count.to_f / page_size).ceil,
      page_size: page_size,
      current_page: page_number
    }
  end

  def record_attributes
    params.fetch(:data, {}).fetch(:attributes, {})
  end

  def record_relationships
    params.fetch(:data, {}).fetch(:relationships, {})
  end

  def render_validation_errors errors
    render_error errors
  end

  def render_error(error)
    error_hash = ErrorSerializer.serialize(error)
    render json: error_hash, status: error_hash[:errors][0][:status]
  end

  private

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def set_default_response_format
      request.format = :json unless params[:format]
    end
end
