Rails.application.routes.draw do
  root "dashboards#show"

  devise_for :users

  get  '/auth/:provider/login',    to: 'auth#login',   as: :oauth_login
  get  '/auth/:provider/callback', to: 'auth#callback'

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
