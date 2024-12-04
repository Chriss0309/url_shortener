Rails.application.routes.draw do
  # Root route for the URL submission form
  root 'links#new'

  #RESTful routes for Links Management
  resources :links, only: [:new, :create, :show] do 
    member do
      get :stats
    end
  end

  # Short URL redirect route - this route will be used to redirect users to the original URL
  get '/:short_path', to: 'links#redirect', as: :short
end
