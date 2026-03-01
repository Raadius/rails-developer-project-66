# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  scope module: :web do
    root 'home#index'

    post 'auth/:provider', to: 'auth#request', as: :auth_request
    get  'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    get  'auth/failure', to: 'auth#failure', as: :auth_failure
    delete 'logout', to: 'auth#logout', as: :logout

    resources :repositories, only: %i[index show new create destroy] do
    end
  end
end
