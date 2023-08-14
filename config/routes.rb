Rails.application.routes.draw do
  root "dashboards#show"

  devise_for :users

  resources :tasks
  resources :categories
end
