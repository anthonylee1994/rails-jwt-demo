class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authenticate_user!
    @current_user = User.from_token(auth_token)
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def auth_token
    request.authorization&.split&.last.to_s
  end
end
