# frozen_string_literal: true

class SessionsController < Clearance::SessionsController
  def new
    @signing_in = true
    super
  end

  def create
    email = User.find_by(username: params[:session][:username])&.email

    if email
      params[:session][:email] = email

      user = authenticate(params)

      sign_in(user) do |status|
        if status.success?
          redirect_back_or(url_after_create)
        else
          render_unauthorized("flash.incorrect_password")
        end
      end
    else
      render_unauthorized(I18n.t("username_not_found", username: params[:session][:username]))
    end
  end

  def render_unauthorized(flash_alert)
    flash.now.alert = flash_alert
    @signing_in = true

    render(template: "sessions/new", status: :unauthorized)
  end
end
