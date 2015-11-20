class PasswordsController < ApplicationController

  def create
  	user = User.find_by(email: params[:user][:email])
  	if user && user.forgot_password!
  		render json: user
  	else
  		render_no_such_email_error
    end
  end

  def update
    user = find_user_by_confirmation_token

    if user && user.update_password(params[:password])
      render json: user
    else
      render_could_not_reset_password_error
    end
  end

  private

	  def find_user_by_confirmation_token
	    Clearance.configuration.user_model.find_by_confirmation_token(params[:id].to_s)
	  end

	  def render_no_such_email_error
	    render json: {errors: {email: ["doesn't exist"]}}, status: 422
	  end

	  def render_could_not_reset_password_error
	    render json: {errors: {password: ["couldn't be reset"]}}, status: 422
	  end
end