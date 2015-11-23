class PasswordsMailer < ActionMailer::Base
  def change_password(user)
    @user = user
    mail from: "help@example.com", to: @user.email,
      subject: "CookAcademy Reset Password"
  end
end