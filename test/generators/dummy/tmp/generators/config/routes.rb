Rails.application.routes.draw do
  resources :posts, module: :content, only: %w[show]
end
