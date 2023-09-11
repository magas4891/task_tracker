class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %w[show edit update destroy]
  before_action :find_prev_category, only: :create

  def index
    @categories = current_user.dashboard.categories

    # render :index
    # if turbo_frame_request?
    #
    # end
  end

  def show
    @tasks = @category.tasks
  end

  def new
    prev_position = Category.find(params[:prevCategoryId]).position
    @category = current_user.dashboard.categories.new(position: prev_position + 1)

    respond_to { | format | format.turbo_stream }
  end

  def create
    @category = current_user.dashboard.categories.new(category_params)

    respond_to { | format | format.turbo_stream if @category.save }
  end

  def edit
    render :new
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.turbo_stream
      else
        format.json { render json: @category.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to categories_path, notice: 'Category was successfully destroyed.' }
    end
  end

  private

  def find_prev_category
    @prev_category = current_user.dashboard.categories.find_by(position: params[:category][:position].to_i - 1)
  end

  def category_params
    params.require(:category).permit(:name, :position)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
