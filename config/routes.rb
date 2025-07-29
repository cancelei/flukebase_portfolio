Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  # Public routes
  get "cv", to: "cv#show"
  get "resume", to: "resumes#show"
  get "chat", to: "chats#show"
  resources :blog_posts, only: [ :index, :show ]
  resources :projects, only: [ :index, :show ]

  # CV Management Routes
  resources :cv_entries do
    collection do
      patch :reorder
    end
  end
  resources :personal_infos, only: [ :show, :update ]
  resources :skills
  resources :educations
  resources :certifications

  # Shared editing (inline editing)
  get "/shared_editing/edit", to: "shared_editing#edit"
  patch "/shared_editing/update", to: "shared_editing#update"

  # Admin routes
  namespace :admin do
    get "/", to: "dashboard#index"
    get "dashboard", to: "dashboard#index"

    resources :projects
    resources :blog_posts
    resources :cv_entries
    resources :subscribers, only: [ :index, :show ]
    resources :site_settings, only: [ :index, :update ]

    # Flukebase settings - single page configuration
    get "flukebase_settings", to: "flukebase_settings#show"
    patch "flukebase_settings", to: "flukebase_settings#update"

    # CV Management in Admin
    get "cv", to: "cv#show"
    resources :personal_infos, only: [ :show, :update ]
    resources :skills
    resources :educations
    resources :certifications
  end

  # Newsletter subscription
  post "subscribe", to: "subscribers#create"

  # Onboarding
  namespace :onboarding do
    resources :steps, only: [ :show, :create ]
  end

  # Chat
  resources :chats, only: [ :show, :create ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
