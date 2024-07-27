# Clearance has this built-in, but `require "clearance/rspec"` wasn't working, so just doing this manually for now.
def sign_in(user)
  params = {
    session: {
      username: user.username,
      password: user.password,
    },
  }

  post session_path(params)
end
