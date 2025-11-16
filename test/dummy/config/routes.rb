Rails.application.routes.draw do
  resources :posts, path: "blog", module: :content, only: %w[index show]
  resources :products, path: "/", module: :content, only: %w[index show]
  resources :similar_products, path: "/", module: :content, only: %w[index show]
  resources :pages, path: "/", module: :content, only: %w[show]

  root to: "content/pages#root"
end
