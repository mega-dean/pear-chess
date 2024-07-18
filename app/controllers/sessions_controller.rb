class SessionsController < Clearance::SessionsController
  def new
    @signing_in = true
    super
  end

  def create
    email = User.find_by(username: params[:session][:username])&.email

    if email
      params[:session][:email] = email

      @user = authenticate(params)

      sign_in(@user) do |status|
        if status.success?
          redirect_back_or(url_after_create)
        else
          flash.now.alert = "flash.incorrect_password"
          @signing_in = true

          render(template: "sessions/new", status: :unauthorized)
        end
      end
    else
      flash.now.alert = I18n.t("username_not_found", username: params[:session][:username])
      @signing_in = true

      render(template: "sessions/new", status: :unauthorized)
    end
  end
end
