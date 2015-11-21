class UsersController < ApplicationController
  load_and_authorize_resource param_method: :permitted_params

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

  private

  def permitted_params
    params.require(:user).permit(:email, :username, :password)
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end
end
