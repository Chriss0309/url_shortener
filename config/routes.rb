Rails.application.routes.draw do
  # Root route points to the URL submission form where users can create new shortened links
  root 'links#new'

  # RESTful routes for Links resource with limited actions:
  resources :links, only: [:new, :create, :show] do 
    member do
      # Stats route provides analytics/tracking data for individual links
      get :stats
    end
  end

  # Short URL redirect route
  # Matches /:short_path where short_path is the generated unique url
  # Redirects visitors to the original URL while tracking visit data
  get '/:short_path', to: 'links#redirect', as: :short
end
