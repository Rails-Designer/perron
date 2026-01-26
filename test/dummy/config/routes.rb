Rails.application.routes.draw do
  resource :search, module: :perron, only: %w[show]

  resources :authors, module: :content, only: %w[show]
  resources :features, path: "blog", module: :content, only: %w[show]
  resources :pages, path: "/", module: :content, only: %w[show]
  resources :posts, path: "blog", module: :content, only: %w[index show]
  resources :products, path: "/", module: :content, only: %w[index show]
  resources :similar_products, path: "/", module: :content, only: %w[index show]

  root to: "content/pages#root"
end
