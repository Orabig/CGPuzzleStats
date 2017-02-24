Rails.application.routes.draw do
  resources :puzzles
  resources :players
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/players/:name/search', to: 'players#search'
end
