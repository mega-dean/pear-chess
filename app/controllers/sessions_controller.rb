class SessionsController < Clearance::SessionsController
  def new
    @signing_in = true
    super
  end

  def create
    @user = authenticate(params)

    sign_in(@user) do |status|
      if status.success?
        redirect_back_or(url_after_create)
      else
        flash.now.alert = "flash.session_create_failure"
        @signing_in = true

        render(template: "sessions/new", status: :unauthorized)
      end
    end
  end
end
