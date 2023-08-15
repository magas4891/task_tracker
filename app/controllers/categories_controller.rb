class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %w[show edit update destroy]

  def index
    @categories = current_user.dashboard.categories
  end

  def show
    @tasks = @category.tasks
  end

  def new
    @category = current_user.dashboard.categories.build
  end

  def create
    @category = current_user.dashboard.categories.new(category_params)

    respond_to do |format|
      if @category.save
        format.turbo_stream
        format.json { render json: { new_category: @category } }
        format.html { redirect_to category_url(@category), notice: 'Category was successfully created.' }
      end
    end
  end

  def edit
    render :new
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.turbo_stream
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

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
