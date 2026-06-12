require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { User.create!(username: "anthony", password: "password123") }
  let(:headers) { { "Authorization" => "Bearer #{user.token}" } }

  describe "GET /tasks" do
    it "lists only the current user's tasks" do
      other_user = User.create!(username: "other", password: "password123")
      task = user.tasks.create!(name: "Build API")
      other_user.tasks.create!(name: "Hidden task")

      get "/tasks", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to contain_exactly(
        a_hash_including("id" => task.id, "name" => "Build API", "completed" => false)
      )
    end

    it "returns a refreshed JWT for authenticated requests" do
      get "/tasks", headers: headers

      token = response.headers["Authorization"].split.last
      payload = JsonWebToken.decode(token)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
      expect(payload["sub"]).to eq(user.id)
      expect(payload["username"]).to eq(user.username)
    end

    it "rejects unauthenticated requests" do
      get "/tasks"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["Authorization"]).to be_nil
      expect(response.parsed_body["error"]).to eq("Unauthorized")
    end

    it "rejects tokens sent without a Bearer prefix" do
      user = User.create!(username: "anthony", password: "password123")

      get "/tasks", headers: { "Authorization" => user.token }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /tasks/:id" do
    it "shows the current user's task" do
      task = user.tasks.create!(name: "Build API", completed: false)

      get "/tasks/#{task.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => task.id,
        "name" => "Build API",
        "completed" => false
      )
    end

    it "does not show another user's task" do
      other_user = User.create!(username: "other", password: "password123")
      task = other_user.tasks.create!(name: "Hidden task", completed: false)

      get "/tasks/#{task.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /tasks" do
    it "creates a task for the current user" do
      expect do
        post "/tasks", params: { name: "Build API" }, headers: headers
      end.to change(user.tasks, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include(
        "name" => "Build API",
        "completed" => false
      )
    end

    it "returns validation errors for invalid params" do
      post "/tasks", params: { name: "" }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("Name can't be blank")
    end
  end

  describe "PUT /tasks/:id" do
    it "updates the current user's task" do
      task = user.tasks.create!(name: "Build API", completed: false)

      put "/tasks/#{task.id}", params: { name: "Ship API", completed: true }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => task.id,
        "name" => "Ship API",
        "completed" => true
      )
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes the current user's task" do
      task = user.tasks.create!(name: "Build API", completed: false)

      expect do
        delete "/tasks/#{task.id}", headers: headers
      end.to change(user.tasks, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
