Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
     post '/films', to: 'films#search'
     post '/films/imdb_id', to: 'films#find_by_imdb_id'
     post '/films/info', to: 'films#info'
     post '/films/download', to: 'films#download'
     post '/films/thumbnail', to: 'films#thumbnail'
     post '/films/4k', to: 'films#get_4k'
     post '/films/tv', to: 'films#tv_search'
     post '/films/get_seasons', to: 'films#get_seasons'
    end
  end
  get "/tv", to: "home#tv"
  get "/film", to: 'home#index'
  root to: 'home#index'
end
