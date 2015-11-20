class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  include Clearance::Controller

  rescue_from CanCan::AccessDenied do |exception|
    render nothing: true, status: :unauthorized
  end

  include Clearance::Controller

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

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
