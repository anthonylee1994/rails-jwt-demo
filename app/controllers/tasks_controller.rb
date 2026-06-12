class TasksController < ApplicationController
  before_action :set_task, only: %i[ show update destroy ]

  def index
    # If a serializer ever starts including the task's `user` (or any other
    # association), add `.includes(:user)` here to avoid an N+1.
    render json: current_user.tasks.order(created_at: :desc)
  end

  def show
    render json: @task
  end

  def create
    task = current_user.tasks.new(task_params)

    if task.save
      render json: task, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @task.destroy!

    head :no_content
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.permit(:name, :completed)
  end
end
