class SessionsController < Clearance::SessionsController
  def new
    @signing_in = true
  end
end
