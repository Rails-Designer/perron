---
section: content
position: 5
title: Routes
description: Perron uses Rails' routing mechanism, keeping things simple and easy.
---

Perron uses standard Rails routing, allowing the use of familiar route helpers.

The `config/routes.rb` could look like this:
```ruby
Rails.application.routes.draw do
  resources :posts, module: :content, only: %w[index show]
  resources :pages, module: :content, only: %w[show]

  root to: "content/pages#root"
end
```

## Route configuration

When using `_url` route helpers, configure `default_url_options` in the Perron initializer:
```ruby
Perron.configure do |config|
  # …
  config.default_url_options = {host: "perron.railsdesigner.com", protocol: "https", trailing_slash: true}
  # …
end
```

> [!tip]
> You can also set (or override) these values with environment variables: `PERRON_HOST`, `PERRON_PROTOCOL` and `PERRON_TRAILING_SLASH`

For a typical "clean slug", the filename without extension serves as the `id` parameter.
```ruby
<%# For app/content/posts/announcement.md %>
<%= link_to "Announcement", post_path("announcement") %>
```
This would render `<a href="/posts/announcement/">Announcement</a>`.


## Additional routes

Include additional routes in the build beyond collections:
```ruby
Perron.configure do |config|
  config.additional_routes = %w[search_path]
end
```


## Path building

Perron builds paths from your defined routes rather than collections. This ensures URLs match exactly what gets built, including any nested route structures.

For route-based path building, the collection is derived from:
1. The controller's `collection_name` method (if defined)
2. The route resource name (singularized)

For example, `resources :posts` maps to the `posts` collection and builds paths like `/posts/my-post`.
