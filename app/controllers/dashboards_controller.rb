class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    set_instance_variables
  end

  def categories_reorder
    category = current_user.dashboard.categories.find_by(position: params[:old_position])
    category.insert_at(params[:new_position])
    set_instance_variables

    head :ok
  end

  def tasks_reorder
    from_category, to_category = set_categories
    task                       = current_user.tasks.find_by(category: from_category, position: params[:old_position])
    task.update(category: to_category) unless params[:from].eql?(params[:to])
    task.insert_at(params[:new_position])
    set_instance_variables

    head :ok
  end

  private

  def set_instance_variables
    @categories = current_user.dashboard.categories.order(position: :asc)
    @tasks      = current_user.tasks.uncategorized.order(position: :asc)
  end

  def set_categories
    from = params[:from].eql?('nil') ? nil : params[:from]
    to   = params[:to].eql?('nil') ? nil : Category.find(params[:to])

    [from, to]
  end
end
