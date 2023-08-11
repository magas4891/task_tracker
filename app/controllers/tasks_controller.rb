class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %w[edit update destroy]

  def index
    @categories = current_user.categories.populated_category_tasks
    @tasks = current_user.tasks
  end

  def edit
    render :new
  end

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
        format.html { redirect_to task_url(@task), notice: 'Task was successfully created.' }
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
    params.require(:task).permit(:title, :description, :due_date, :category_id)
  end
end
