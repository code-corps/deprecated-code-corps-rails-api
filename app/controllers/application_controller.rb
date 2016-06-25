class ApplicationController < ActionController::API
  include Clearance::Controller
  include Pundit

  before_action :set_default_response_format
  before_action :set_raven_context

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

  def analytics
    @analytics ||= Analytics.new(current_user)
  end

  def page_size
    params.fetch(:page, {}).fetch(:size, 10).to_i
  end

  def page_number
    params.fetch(:page, {}).fetch(:number, 1).to_i
  end

  def meta_for(object_count)
    {
      total_records: object_count,
      total_pages: (object_count.to_f / page_size).ceil,
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

  def render_validation_errors(errors)
    render_error errors
  end

  def render_error(error)
    error_hash = ErrorSerializer.serialize(error)
    render json: error_hash, status: error_hash[:errors][0][:status]
  end

  def parse_params(params, options = {})
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, options)
  end

  def require_param(key)
    parse_params(params)[key].presence || raise(ActionController::ParameterMissing.new(key))
  end

  def params_for_user(params)
    params.merge(user_id: current_user.id)
  end

  private

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def set_default_response_format
      request.format = :json unless params[:format]
    end

    def set_raven_context
      if signed_in?
        Raven.user_context(id: current_user.id)
      end
    end
end
