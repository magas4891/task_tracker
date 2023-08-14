class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard

  def show
    @categories = @dashboard.categories
    @tasks = current_user.tasks.uncategorized
  end

  private

  def set_dashboard
    @dashboard = current_user.dashboard
  end
end
