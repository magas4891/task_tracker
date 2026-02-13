class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %w[show edit update destroy edit_name]
  before_action :find_prev_category, only: :create

  def index
    @categories = current_user.dashboard.categories
  end

  def show
    @tasks = @category.tasks
  end

  def new
    puts "params: #{params}"
    position = if params[:prevCategoryId].present?
      Category.find(params[:prevCategoryId]).position + 1
    else
      last = current_user.dashboard.categories.order(position: :asc).last
      last ? last.position + 1 : 0
    end
    @category = current_user.dashboard.categories.new(position: position)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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

  def edit_name
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("category_name_#{@category.id}",
                                                                      partial: 'categories/edit_name',
                                                                      locals: { category: @category }) }
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
