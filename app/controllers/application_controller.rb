class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  include Clearance::Controller

  before_action :set_default_response_format

  rescue_from CanCan::AccessDenied do |e|
    render_error e
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

  def record_attributes
    params.require(:data).fetch(:attributes, {})
  end

  def render_validation_errors errors
    render_error errors
  end

  def render_error(error)
    error_hash = ErrorSerializer.serialize(error)
    render json: error_hash, status: error_hash[:errors][0][:status]
  end

  def record_relationships
    params.require(:data).fetch(:relationships, {})
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def set_default_response_format
    request.format = :json unless params[:format]
  end
end
