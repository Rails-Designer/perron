Rails.application.routes.draw do
  resources :posts, module: :content, only: %w[index show]
end
