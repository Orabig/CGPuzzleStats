Rails.application.routes.draw do
  resources :puzzles do
    collection do
	  get 'seed'
	end
  end
  resources :players do
    collection do
	  get 'search'
	  get 'save'
	end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
