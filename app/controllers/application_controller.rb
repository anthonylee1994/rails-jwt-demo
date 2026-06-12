class ApplicationController < ActionController::API
  BEARER_PREFIX = "Bearer "

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
    header = request.authorization.to_s
    return "" unless header.start_with?(BEARER_PREFIX)

    header.delete_prefix(BEARER_PREFIX)
  end

  # Sliding-session: every authenticated response carries a fresh JWT
  # (24h exp) so clients can keep using the most recent token from the
  # `Authorization` response header.
  def refresh_authorization_header
    return unless current_user

    response.headers["Authorization"] = "Bearer #{current_user.token}"
  end
end
