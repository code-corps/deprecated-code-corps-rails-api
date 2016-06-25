class PasswordsMailer < ActionMailer::Base
  def change_password(user)
    @user = user
    mail from: "team@codecorps.org", to: @user.email,
      subject: "Code Corps Reset Password"
  end
end
