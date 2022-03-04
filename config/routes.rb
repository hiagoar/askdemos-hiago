Rails.application.routes.draw do
  devise_for :users
  resources :inboxes do
    resources :messages, only: %i[new create destroy], module: :inboxes do
      member do
        patch :upvote
      end
    end
  end
  root 'static_pages#landing_page'
  get 'pricing', to: 'static_pages#pricing'
  get 'privacy', to: 'static_pages#privacy'
  get 'terms', to: 'static_pages#terms'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
