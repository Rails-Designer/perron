Rails.application.routes.draw do
  resource :search, module: :perron, path: "search.json", only: %w[show]

  resources :showcases, module: :content, path: "showcase", only: %w[index]
  resources :resources, module: :content, path: "library", only: %w[index show] do
    resource :template, path: "template.rb", module: :resources, only: %w[show]
  end
  resources :categories, module: :content, path: "library/category", constraints: { id: /#{Content::Resource::TYPES.keys.join("|")}/ }, only: %w[show]

  resources :articles, path: "docs", module: :content, only: %w[index show] do
    get ":id.md", to: "articles/markdown#show", as: :markdown, on: :collection
  end
  resources :llms, module: :content, path: "/", only: %w[show], constraints: { id: /llms\.txt|llms-full\.txt/ }

  resources :pages, module: :content, path: "/", only: %w[show]

  root to: "content/pages#root"
end
