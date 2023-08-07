class CategoriesController < ApplicationController
  def create
    category = current_user.categories.create(category_params)

    respond_to do |format|
      format.json { render json: { new_category: category } }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
