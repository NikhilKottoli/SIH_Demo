Rails.application.routes.draw do
  root "home#home"
  get "/data" => "home#data"

  get "up" => "rails/health#show", as: :rails_health_check

  post 'upload', to: 'home#upload'
  
  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

end
