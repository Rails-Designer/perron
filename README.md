# Perron

A Rails-based static site generator.

**Sponsored By [Rails Designer](https://railsdesigner.com/)**

<a href="https://railsdesigner.com/" target="_blank">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Rails-Designer/perron/HEAD/.github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Rails-Designer/perron/HEAD/.github/logo-light.svg">
    <img alt="Rails Designer" src="https://raw.githubusercontent.com/Rails-Designer/perron/HEAD/.github/logo-light.svg" width="240" style="max-width: 100%;">
  </picture>
</a>


## Getting Started

### Installation

Start by adding Perron:
```bash
bundle add perron
```

Then generate the initializer:
```bash
rails generate perron:install
```


This creates an initializer:
```ruby
Perron.configure do |config|
  config.site_name = "AppRefresher"
end
```


## Mode

Perron can operate in two modes, configured via `config.mode`. This allows you to build either a full static site or integrate pages into a dynamic Rails application.

| **Mode** | `:standalone` (default) | `:integrated` |
| :--- | :--- | :--- |
| **Use Case** | Full static site for hosts like Netlify/Vercel | Add static pages to a live Rails app |
| **Output** | `output/` directory | `public/` directory |
| **Asset Handling** | Via Perron | Via Asset Pipeline |


## Creating Content

Perron is, just like Rails, designed with convention over configuration in mind. Content is stored in `app/content/*/*.{erb,md}`. Content is backed by a class, located in `app/models/content/` that inherits from `Perron::Resource`.

The controllers are located in `app/controllers/content/`. To make them available, create a route: `resources :posts, module: :content, only: %w[index show]`.


### Collections

```bash
bin/rails generate content Post
```

This will create the following files:

* `app/models/content/post.rb`
* `app/controllers/content/posts_controller.rb`
* `app/views/content/posts/index.html.erb`
* `app/views/content/posts/show.html.erb`
* Adds route: `resources :posts, module: :content, only: %w[index show]`


### Setting a Root Page

To set a root page, include `Perron::Root` in your `Content::PagesController` and add a `app/content/pages/root.[md,erb]` file (make sure to set `slug: "/"` in its frontmatter).

This is automatically added when you create a `Page` collection.


## Markdown Support

Perron supports markdown with the `markdownify` helper.

There are no markdown gems bundled by default, so you'll need to add one of these:

- CommonMarker
- Kramdown
- Redcarpet

```bash
bundle add {commonmarker,kramdown,redcarpet}
```


## HTML Transformations

Perron can post-process the HTML generated from your Markdown content.


### Usage

Apply transformations by passng an array of processor names or classes to the `markdownify` helper via the `process` option.
```erb
<%= markdownify @resource.content, process: %w[target_blank lazy_load_images] %>
```


### Available Processors

The following processors are built-in and can be activated by passing their string name:

- `target_blank`: Adds `target="_blank"` to all external links;
- `lazy_load_images`: Adds `loading="lazy"` to all `<img>` tags.


### Creating Your Own

You can create your own processor by defining a class that inherits from `Perron::HtmlProcessor::Base` and implements a `process` method.
Then, pass the class constant directly in the `process` array.

```ruby
# app/processors/add_nofollow_processor.rb
class AddNofollowProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("a[target=_blank]").each { it["rel"] = "nofollow" }
  end
end
```

```erb
<%= markdownify @resource.content, process: ["target_blank", AddNofollowProcessor] %>
```


## Data Files

Perron can consume structured data from YML, JSON, or CSV files, making them available within your templates.
This is useful for populating features, team members, or any other repeated data structure.

### Usage

To use a data file, instantiate `Perron::Data` with the basename of the file and iterate over the result.
```erb
<% Perron::Data.new("features").each do |feature| %>
  <h4><%= feature.name %></h4>
  <p><%= feature.description %></p>
<% end %>
```

### File Location and Formats

By default, Perron looks up `app/content/data/` for files with a `.yml`, `.json`, or `.csv` extension.
For a `new("features")` call, it would find `features.yml`, `features.json`, or `features.csv`. You can also provide a full, absolute path to any data file.

### Accessing Data

The wrapper object provides flexible, read-only access to each record's attributes. Both dot notation and hash-like key access are supported.
```ruby
feature.name
feature[:name]
```


## Metatags

The `meta_tags` helper automatically generates SEO and social sharing meta tags for your pages.


### Usage

In your layout (e.g., `app/views/layouts/application.html.erb`), add the helper to the `<head>` section:
```erb
<head>
  …
  <%= meta_tags %>
  …
</head>
```

You can render specific subsets of tags:
```erb
<%= meta_tags only: %w[title description] %>
```

Or exclude certain tags:
```erb
<%= meta_tags except: %w[twitter_card twitter_image] %>
```

### Priority

Values are determined with the following precedence, from highest to lowest:

#### 1. Controller Action

Define a `@metadata` instance variable in your controller:
```ruby
class Content::PostsController < ApplicationController
  def index
    @metadata = {
      title: "All Blog Posts",
      description: "A collection of our articles."
    }
    @resources = Content::Post.all
  end
end
```

#### 2. Page Frontmatter

Add values to the YAML frontmatter in content files:

```yaml
---
title: My Awesome Post
description: A deep dive into how meta tags work.
image: /assets/images/my-awesome-post.png
author: Kendall
---

Your content here…
```

#### 3. Default Values

Set site-wide defaults in the initializer:
```ruby
Perron.configure do |config|
  # …

  config.metadata.description = "AI-powered tool to keep your knowledge base articles images/screenshots and content up-to-date"
  config.metadata.author = "Rails Designer"
end
```


## Building Your Static Site

When in `standalone` mode and you're ready to generate your static site, run:
```bash
RAILS_ENV=production rails perron:build
```

This will create your static site in the configured output directory (`output` by default).


## Sites using Perron

Sites that use Perron.

### Standalone (as a SSG)
- [AppRefresher](https://apprefresher.com)

### Integrated (part of a Rails app)
- [Rails Designers (private community for Rails UI engineers](https://railsdesigners.com)


## Contributing

This project uses [Standard](https://github.com/testdouble/standard) for formatting Ruby code. Please run `be standardrb` before submitting pull requests. Run tests with `rails test`.


## License

Perron is released under the [MIT License](https://opensource.org/licenses/MIT).
