Rails.application.routes.draw do
  root "loto7_winning_results#index"
  
  resources :loto7_winning_results, only: [:index, :show] do
    collection do
      post :update_from_web
    end
  end
  resources :loto7_purchases, only: [:index, :create, :destroy] do
    collection do
      post 'check_results'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
