class UsersController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:show_authenticated_user, :update, :update_authenticated_user]

  skip_before_action do
    load_and_authorize_resource param_method: :permitted_params, only: [:reset_password, :update, :update_authenticated_user]
  end

  def create
    user = User.new(permitted_params)

    if user.save
      render json: user
    else
      render_validation_errors user.errors
    end
  end

  def show
    user = User.find(params[:id])
    render json: user
  end

  def update
    user = User.find(params[:id])

    authorize! :update, user
    user.update(update_params)

    save_and_render_result user
  end

  def update_authenticated_user
    authorize! :update, current_user
    current_user.update(update_params)

    save_and_render_result current_user
  end

  def show_authenticated_user
    render json: current_user, serializer: AuthenticatedUserSerializer
  end

  def forgot_password
    user = User.find_by(email: params[:user][:email])
    if user && user.forgot_password!
      render json: user
    else
      render_no_such_email_error
    end
  end

  def reset_password
    user = find_user_by_confirmation_token
    if user && user.update_password(params[:user][:password])
      render json: user
    else
      render_could_not_reset_password_error
    end
  end

  private

    def save_and_render_result(record)
      if record.save
        render json: record
      else
        render_validation_errors(record.errors)
      end
    end

    def permitted_params
      params.require(:user).permit(:email, :username, :password, :confirmation_token,)
    end

    def update_params
      record_attributes.permit(:website, :biography, :twitter)
    end

    def render_no_such_email_error
      render json: {errors: {email: ["doesn't exist"]}}, status: 422
    end

    def render_could_not_reset_password_error
      render json: {errors: {password: ["couldn't be reset"]}}, status: 422
    end

    def find_user_by_confirmation_token
      User.find_by(confirmation_token: params[:user][:confirmation_token])
    end
end
