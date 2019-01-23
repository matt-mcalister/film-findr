Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
     post '/films', to: 'films#search'
     post '/films/download', to: 'films#download'
     post '/films/thumbnail', to: 'films#thumbnail'
    end
  end
  get "/tv", to: "home#tv"
  root to: 'home#index'
end
