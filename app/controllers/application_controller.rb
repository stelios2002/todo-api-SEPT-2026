# Client sends a bearer token in the header. Keeps only the token with split. Throw unauthorized error or not found user error/
class ApplicationController < ActionController::API
  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?

    if token.blank?
      return render json: { error: "Missing token" }, status: :unauthorized
    end

    decoded = JsonWebToken.decode(token)

    if decoded.blank?
      return render json: { error: "Invalid or expired token" }, status: :unauthorized
    end

    @current_user = User.find_by(id: decoded[:user_id])

    if @current_user.nil?
      render json: { error: "User not found" }, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Todo not found" }, status: :not_found
  end
end