# Login if user exists and the password is correct (email + password).
# Logout is just a message not a state, this mock server doesn't keep active sessions.
class AuthenticationController < ApplicationController
  before_action :authorize_request, only: [:me]

  def login
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        message: "Logged in successfully",
        token: token,
        user: { id: user.id, name: user.name, email: user.email }
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def logout
    render json: { message: "Logged out successfully. Please discard your token." }, status: :ok
  end

  def me
    render json: { user: { id: current_user.id, name: current_user.name, email: current_user.email } }, status: :ok
  end
end