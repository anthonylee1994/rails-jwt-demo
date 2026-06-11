class AuthController < ApplicationController
  def register
    user = User.new(user_params)

    if user.save
      render json: auth_response(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      render json: auth_response(user), status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:username, :password)
  end

  def auth_response(user)
    { token: user.token }
  end
end
