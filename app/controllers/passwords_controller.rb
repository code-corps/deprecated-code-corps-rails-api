class PasswordsController < ApplicationController

  def create
    user = User.find_by(email: params[:user][:email])
    if user && user.forgot_password!
      render json: user
    else
      render_no_such_email_error
    end
  end

  private

  def render_no_such_email_error
    render json: {errors: {email: ["doesn't exist"]}}, status: 422
  end
end