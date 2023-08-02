class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %w[edit update destroy]

  def index
    @tasks = current_user.tasks
  end

  def edit; end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.turbo_stream
      end
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.new(task_params)

    respond_to do |format|
      if @task.save
        format.turbo_stream
        format.html { redirect_to task_url(@task), notice: 'Task was successfully updated.' }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tasks_path, notice: 'Task was successfully destroyed.' }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date)
  end
end
