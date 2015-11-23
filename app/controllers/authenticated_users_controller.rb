class AuthenticatedUsersController < ApplicationController
  before_action :doorkeeper_authorize!
  load_and_authorize_resource param_method: :permitted_params

  def show
    render json: current_user
  end

    private

    def permitted_params
      params.require(:user).permit(:email, :username, :password, :confirmation_token,)
    end

end
