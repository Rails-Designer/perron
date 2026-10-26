---
section: getting_started
position: 1
title: Quick-start guide
description: Learn how to get started quickly with Perron.
---

Perron is a gem that generates static sites from your Rails app.

## Requirements

- Ruby 3.4+
- Rails 7.0+


## Quickstart

Run
```bash
rails new my-new-site --minimal -T -O -m https://perron.railsdesigner.com/library/new/template.rb
```


## Manual installation

Start by adding Perron to your Rails app:
```bash
bundle add perron

bin/rails perron:install
```

This creates a configuration file at `config/initializers/perron.rb`:
```ruby
Perron.configure do |config|
  config.site_name = "Chirp Form"

  # config.site_description = "Description for meta tags"
  # config.default_url_options = {host: "chirpform.com", protocol: "https"}
end
```

## Create your first content

Perron organizes content into collections. Each collection needs:

- a resource class in `app/models/content/`
- a controller in `app/controllers/content/`
- views in `app/views/content/`
- content files in `app/content/{collection_name}/`

Use the built-in generator to create one:
```bash
bin/rails generate content Post
```

This creates:
- `app/content/posts/`; content files go here
- `app/models/content/post.rb`; resource class
- `app/controllers/content/posts_controller.rb`
- `app/views/content/posts/`

And adds a route: `resources :posts, module: :content, only: %w[index show]`


## Add content

Create your first article in `app/content/posts/hello-world.md`:
```markdown
---
title: Hello World
description: My first Perron post
---

# Hello World

This is my first post built with Perron!
```

Then run the Rails server to see your site:
```bash
bin/dev
```

Visit `http://localhost:3000/posts/hello-world` to see your content.


## Build for production

Generate static files for deployment:
```bash
RAILS_ENV=production bin/rails perron:build
```

This creates HTML files in the `/output/` directory, ready to deploy to any static hosting platform.

> [!tip]
> Browse the [Library](/library/category/snippet/) for deployment templates to platforms like Netlify, [Seal Static](https://sealstatic.com) and statichost.eu.
