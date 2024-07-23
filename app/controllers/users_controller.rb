# frozen_string_literal: true

class UsersController < Clearance::UsersController
  def new
    @signing_in = true
    super
  end

  def create
    @user = User.new(
      username: params[:user][:username],
      email: params[:user][:email],
      password: params[:user][:password],
    )

    if @user.save
      sign_in(@user)
      redirect_back_or(url_after_create)
    else
      flash.now.alert = "flash.session_create_failure"
      @signing_in = true

      render(template: "users/new", status: :unprocessable_entity)
    end
  end
end
