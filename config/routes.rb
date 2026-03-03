Rails.application.routes.draw do
  root "dashboards#show"

  devise_for :users

  get  '/auth/x',          to: 'auth#login',   as: :auth_x
  get  '/auth/x/callback', to: 'auth#callback'

  resources :tasks
  resources :categories do
    member do
      get :edit_name  # GET /categories/:id/edit_name
    end
  end
  resources :dashboards, only: :show do
    collection do
      patch :categories_reorder
      patch :tasks_reorder
    end
  end
end
