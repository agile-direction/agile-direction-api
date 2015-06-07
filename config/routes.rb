Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :missions
    end
  end

  root 'application#index'
  get '*unmatched_route', :to => 'application#index'
end
