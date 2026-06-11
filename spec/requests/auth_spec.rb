require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /auth/register" do
    it "creates a user and returns a JWT" do
      expect do
        post "/auth/register", params: {
          username: "anthony",
          password: "password123"
        }
      end.to change(User, :count).by(1)

      user = User.find_by!(username: "anthony")
      payload = JsonWebToken.decode(response.parsed_body["token"])

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.keys).to contain_exactly("token")
      expect(payload["sub"]).to eq(user.id)
      expect(payload["username"]).to eq("anthony")
    end

    it "returns validation errors for invalid params" do
      expect do
        post "/auth/register", params: {
          username: "",
          password: "password123"
        }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("Username can't be blank")
    end
  end

  describe "POST /auth/login" do
    it "returns a JWT for valid credentials" do
      user = User.create!(username: "anthony", password: "password123")

      post "/auth/login", params: {
        username: "anthony",
        password: "password123"
      }

      token = response.parsed_body["token"]
      payload = JsonWebToken.decode(token)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.keys).to contain_exactly("token")
      expect(payload["sub"]).to eq(user.id)
      expect(payload["username"]).to eq("anthony")
    end

    it "rejects invalid credentials" do
      User.create!(username: "anthony", password: "password123")

      post "/auth/login", params: {
        username: "anthony",
        password: "wrong-password"
      }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Invalid username or password")
    end
  end
end
