Rails.application.routes.draw do
  devise_for :users

  # Public routes
  root "home#index"

  resources :projects, only: [ :index, :show ]
  resources :blog_posts, path: "blog", only: [ :index, :show ]

  get "/cv", to: "cv#show"
  resources :cv_entries, only: [ :create, :update, :destroy ]
  get "/resume", to: "resumes#show"
  get "/chat", to: "chats#show"
  post "/chat", to: "chats#create"

  post "/subscribe", to: "subscribers#create"

  # Shared editing routes (authenticated users only)
  get "/shared_editing/edit", to: "shared_editing#show"
  patch "/shared_editing/update", to: "shared_editing#update"

  # Admin routes (protected by authentication)
  namespace :admin do
    get "/dashboard", to: "dashboard#index"

    resources :projects
    resources :blog_posts
    resources :resumes
    get "/cv", to: "cv#show"

    resources :subscribers, only: [ :index, :show, :destroy ]
    resources :chat_messages, only: [ :index, :show, :destroy ]

    # Settings
    resources :site_settings, only: [ :index, :update ]
    resources :smtp_settings, only: [ :show, :update ] do
      member do
        post :test
      end
    end

    # Flukebase integration
    get "/flukebase/settings", to: "flukebase_settings#show", as: "flukebase_settings"
    patch "/flukebase/settings", to: "flukebase_settings#update"
    post "/flukebase/settings/test", to: "flukebase_settings#test_connection", as: "flukebase_settings_test"
    post "/flukebase/settings/sync", to: "flukebase_settings#sync_now", as: "flukebase_settings_sync"
    post "/flukebase/sync", to: "flukebase#sync"

    # Domain setup
    get "/domain/setup", to: "domain#setup"
    patch "/domain/setup", to: "domain#update"
  end

  # Onboarding routes
  namespace :onboarding do
    get "/", to: "steps#index"
    get "/step/:step", to: "steps#show", as: :step
    patch "/step/:step", to: "steps#update"
    post "/complete", to: "steps#complete"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
