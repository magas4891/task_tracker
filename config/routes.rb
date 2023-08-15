Rails.application.routes.draw do
  root "dashboards#show"

  devise_for :users

  resources :tasks
  resources :categories
  resources :dashboards, only: :show do
    collection do
      patch :categories_reorder
      patch :tasks_reorder
    end
  end
end
