Rails.application.routes.draw do
  resource :search, module: :perron, only: %w[show]

  resources :authors, module: :content, only: %w[show] do
    get ":id.html", to: "authors#show", as: :html, on: :collection
  end
  resources :features, path: "features", module: :content, only: %w[show]
  resources :pages, path: "/", module: :content, only: %w[show]
  resources :members, module: :content, path: "team", only: %w[index show]
  resources :posts, path: "blog", module: :content, only: %w[index show] do
    resource :template, path: "template.rb", module: :posts, only: %w[show]
  end
  get "/blog/:id", to: "content/posts/categories#show", constraints: {id: /#{Content::Post::CATEGORIES.keys.join("|")}/}, as: :posts_category
  resources :products, path: "/", module: :content, only: %w[index show]

  resources :similar_products, path: "/", module: :content, only: %w[index show]

  root to: "content/pages#root"
end
