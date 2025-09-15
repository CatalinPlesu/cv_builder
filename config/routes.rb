Rails.application.routes.draw do
  resources :templates
  resources :cv_headings, only: [] do
    collection do
      get :edit
      put :upsert
    end

    resources :cv_heading_items, only: [] do
      collection do
        patch :reorder
      end
    end
  end
  resources :tags, only: [] do
    collection do
      get :edit
      put :upsert
    end
  end

  resources :skills, only: [] do
    collection do
      get :edit
      put :upsert
    end
  end

  resources :projects, only: [] do
    collection do
      get :edit
      put :upsert
    end
  end

  resources :experiences, only: [] do
    collection do
      get :edit
      put :upsert
    end
  end

  resources :educations, only: [] do
    collection do
      get :edit
      put :upsert
    end
  end

  resources :master_cv, only: [ :index ]

  get "dashboard", to: "dashboard#index", as: :dashboard
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "home#index"
  get "home/index"
end
