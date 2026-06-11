class ApplicationController < ActionController::API
  attr_reader :current_user

  before_action :authenticate_user!
  after_action :refresh_authorization_header

  private

  def authenticate_user!
    @current_user = User.from_token(auth_token)
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def auth_token
    request.authorization&.split&.last.to_s
  end

  def refresh_authorization_header
    return unless current_user

    response.headers["Authorization"] = "Bearer #{current_user.token}"
  end
end
