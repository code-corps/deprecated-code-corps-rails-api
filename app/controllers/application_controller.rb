class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  include Clearance::Controller

  before_action :set_default_response_format

  rescue_from CanCan::AccessDenied do |exception|
    render nothing: true, status: :unauthorized
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
    render json: {errors: errors.to_h}, status: 422
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def set_default_response_format
    request.format = :json unless params[:format]
  end
end
